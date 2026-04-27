# PR#4038の実装
https://github.com/ruby/ruby/blob/0820228d29fa8de223f21043fb51988d32bfa97c/ext/socket/lib/socket.rb

```ruby
def self.tcp(host,
             port,
             local_host = nil,
             local_port = nil,
             connect_timeout: nil,
             resolv_timeout: nil) # :yield: socket

  # ----------------------------------
  # 準備
  # ----------------------------------

  last_error = nil
  ret = nil
  start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

  if connect_timeout
    raise ArgumentError, "connect_timeout must be Numeric" unless connect_timeout.is_a?(Numeric)
    raise ArgumentError, "connect_timeout must not be negative" if connect_timeout.negative?
  end

  if resolv_timeout
    raise ArgumentError, "resolv_timeout must be Numeric" unless resolv_timeout.is_a?(Numeric)
    raise ArgumentError, "resolv_timeout must not be negative" if resolv_timeout.negative?
  end

  # デフォルトではIPv6 / IPv4いずれも実行
  attempt_v6 = true
  attempt_v4 = true
  local_addr_list = nil

  if local_host != nil || local_port != nil
    # local_hostかlocal_portがある場合は接続ソケットにバインドするためのアドレスリストを取得しておく
    local_addr_list = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)

    # ユーザが指定したlocal_host / local_portがある場合はアドレスファミリごとに実行の有無を保持
    attempt_v6 = local_addr_list.any? {|local_ai| local_ai.afamily == Socket::AF_INET6 }
    attempt_v4 = local_addr_list.any? {|local_ai| local_ai.afamily == Socket::AF_INET }
  end

  pipe_read, pipe_write = IO.pipe
  mutex = Mutex.new
  ai_list_v6 = []
  ai_list_v4 = []
  error_queue = Queue.new

  # ----------------------------------
  # Hostname Resolution Query Handling
  # ----------------------------------

  # 1. スレッドを生成
  # 2. ai_list_vn を Addrinfo.getaddrinfo(host, port, :PF_INETn, :STREAM) で置き換えた値を返す
  # 3. pipe_write に getaddrinfo の完了を書き込む (ensure)
  # (IPv4の場合) Resolution Delayを実行し、終了後 pipe_write にResolution Delayの完了を書き込む
  getaddrinfo_v6_th =
    start_getaddrinfo_v6(host, port, mutex, pipe_write, ai_list_v6, error_queue) if attempt_v6
  getaddrinfo_v4_th =
    start_getaddrinfo_v4(host, port, mutex, pipe_write, ai_list_v4, error_queue) if attempt_v4

  # ユーザが指定したresolv_timeoutがある場合はタイムアウト時間分だけgetaddrinfoの終了を待つ
  if resolv_timeout
    timeout_th = Thread.new do
      Thread.current.report_on_exception = false
      sleep(resolv_timeout)
      mutex.synchronize { pipe_write.close() }
    end
  end

  # ----------------------------------
  # Connection Attempts
  # ----------------------------------

  # 接続できたソケット、[<未接続のSocket>]、{ <未接続のSocket> => <接続対象のAddrinfo> }、エラー
  ret, socket_list, addrinfos, last_error =
    make_connection_attempts(pipe_read, attempt_v6, attempt_v4, ai_list_v6, ai_list_v4, local_addr_list)

  # 接続済みのソケットを取得できておらず、[<未接続のSocket>]がある場合
  if !ret && !socket_list.empty?
    ret, last_error = wait_connection(socket_list, addrinfos, connect_timeout, start_time)
  end

  # ----------------------------------
  # ソケットを返すための処理
  # ----------------------------------

  addrinfos.clear()

  # ここまでで接続済みソケットを得られていない場合のエラー処理
  unless ret
    if last_error
      raise last_error
    elsif connect_timeout || resolv_timeout
      raise Errno::ETIMEDOUT, "user specified timeout"
    elsif !error_queue.empty?
      # raise a unhandled exception in getaddrinfo threads
      error = error_queue.pop until error_queue.empty?
      raise error
    else
      raise SocketError, "no appropriate local address"
    end
  end

  ret.nonblock = false
  socket_list.delete(ret)

  if block_given?
    # スレッドとソケットの終了処理
    cleanup_socket_tcp([getaddrinfo_v6_th, getaddrinfo_v4_th, timeout_th],
                       socket_list + [pipe_read, pipe_write])
    begin
      yield ret
    ensure
      ret.close
    end
  else
    return ret
  end
ensure
  unless block_given?
    threads = [getaddrinfo_v6_th, getaddrinfo_v4_th, timeout_th]
    ios = socket_list ? socket_list + [pipe_read, pipe_write] : [pipe_read, pipe_write]
    cleanup_socket_tcp(threads, ios)
  end
end
```

```ruby
def self.start_getaddrinfo_v6(host, port, mutex, pipe_write, ai_list_v6, error_queue)
  return Thread.new do
    Thread.current.report_on_exception = false
    ai_list_v6.replace(Addrinfo.getaddrinfo(host, port, :PF_INET6, :STREAM))
  rescue SocketError => ex
    case ex.message
    when "getaddrinfo: Address family for hostname not supported" # when IPv6 is not supported
      # ignore
    when "getaddrinfo: Temporary failure in name resolution" # when timed out (EAI_AGAIN)
      # ignore
    else
      error_queue.push(ex) # report the exception to main thread
    end
  rescue => ex
    error_queue.push(ex)
  ensure
    mutex.synchronize { pipe_write.putc(GETADDRINFO_V6_DONE) unless pipe_write.closed? }
  end
end

private_class_method :start_getaddrinfo_v6

# 50ms is the recommended value for the resolution delay for IPv4 in RFC8305
RESOLUTION_DELAY = 0.05
private_constant :RESOLUTION_DELAY

def self.start_getaddrinfo_v4(host, port, mutex, pipe_write, ai_list_v4, error_queue)
  return Thread.new do
    Thread.current.report_on_exception = false
    begin
      ai_list_v4.replace(Addrinfo.getaddrinfo(host, port, :PF_INET, :STREAM))
    rescue SocketError => ex
      case ex.message
      when "getaddrinfo: Address family for hostname not supported" # when IPv4 is not supported
        # ignore
      when "getaddrinfo: Temporary failure in name resolution" # when timed out (EAI_AGAIN)
        # ignore
      else
        error_queue.push(ex) # report the exception to main thread
      end
    rescue => ex
      error_queue.push(ex)
    ensure
      mutex.synchronize { pipe_write.putc(GETADDRINFO_V4_DONE) unless pipe_write.closed? }
    end

    unless ai_list_v4.empty? # if getaddrinfo finished successfully
      sleep(RESOLUTION_DELAY) # 50ms is the recommended value for the resolution delay for IPv4 in RFC8305
      mutex.synchronize { pipe_write.putc(RESOLUTION_DELAY_DONE) unless pipe_write.closed? }
    end
  end
end

private_class_method :start_getaddrinfo_v4
```

```ruby
CONNECTION_ATTEMPT_DELAY = 0.25
private_constant :CONNECTION_ATTEMPT_DELAY

def self.make_connection_attempts(pipe_read,
                                  attempt_v6,
                                  attempt_v4,
                                  ai_list_v6,
                                  ai_list_v4,
                                  local_addr_list)
  pipe_reads = [pipe_read]
  socket_list = []
  addrinfos = {}

  getaddrinfo_v6_done = attempt_v6 ? false : true
  getaddrinfo_v4_done = attempt_v4 ? false : true
  resolution_delay_done = false

  last_family = nil
  next_connection_start_time = nil

  # getaddrinfoが完了していない場合、もしくは取得済みのアドレスがある場合
  while !getaddrinfo_v6_done || !getaddrinfo_v4_done || !ai_list_v6.empty? || !ai_list_v4.empty?
    # 2周目以降あり得る値:
    #   socket_list                -> [<未接続のSocket>]
    #   addrinfos                  -> { <未接続のSocket> => <接続対象のAddrinfo> }
    #   getaddrinfo_v6_done        -> GETADDRINFO_V6_DONE 発生の場合、true
    #   getaddrinfo_v4_done        -> GETADDRINFO_V4_DONE 発生の場合、true
    #   resolution_delay_done      -> RESOLUTION_DELAY_DONE 発生の場合、true
    #   last_family                -> 接続する Addrinfo のアドレスファミリ
    #   next_connection_start_time -> 次の接続試行の開始時間

    if next_connection_start_time # 次の接続試行の開始時間が決まっている場合
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      # wait until CONNECTION_ATTEMPT_DELAY is elapsed since last connection attempt
      select_timeout = next_connection_start_time - now
      select_timeout = 0 if select_timeout.negative?
    elsif socket_list.empty?
      select_timeout = nil # wait for events
    else
      select_timeout = CONNECTION_ATTEMPT_DELAY
    end

    # pipe_reads = アドレス解決イベントを捕捉する
    # socket_list = [<未接続のソケット>] が [<接続済みソケット>] になったことを捕捉する
    readable_pipes, writable_sockets, = IO.select(pipe_reads, socket_list, nil, select_timeout)

    # ここを通る可能性があるのは2回目以降
    if writable_sockets && !writable_sockets.empty?
      # [<接続済みソケット>] が本当に接続済みかを確認するために find_connected_socket を呼ぶ
      # 接続済みソケット、エラー、接続失敗ソケットを取得
      ret, error, failed_sockets = find_connected_socket(writable_sockets, addrinfos)
      socket_list -= failed_sockets
      last_error = error if error
      break if ret # ret = 接続できたソケット
    end

    # read待ちのパイプがある場合
    # 1回目のループは必ずここを通る
    if readable_pipes && !readable_pipes.empty? # handle an event
      event = pipe_read.getbyte # パイプからイベントを取得

      if event
        case event
        when GETADDRINFO_V6_DONE
          getaddrinfo_v6_done = true
        when GETADDRINFO_V4_DONE
          getaddrinfo_v4_done = true
        when RESOLUTION_DELAY_DONE
          resolution_delay_done = true
        end
      else # name resolution has timed out
        getaddrinfo_v6_done = true
        getaddrinfo_v4_done = true
      end
    end

    # ここを通る可能性があるのは2回目以降
    # IO.select may return within CONNECTION_ATTEMPT_DELAY
    # make sure CONNECTION_ATTEMPT_DELAY is elapsed from the last connection attempt
    if next_connection_start_time
      now = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      next if now < next_connection_start_time
    end

    # 接続するAddrinfoを選択して取得
    ai = pick_addrinfo(getaddrinfo_v6_done,
                       getaddrinfo_v4_done,
                       resolution_delay_done,
                       ai_list_v6,
                       ai_list_v4,
                       last_family)

    next unless ai # no addrinfo available for now
    last_family = ai.afamily

    local_addr = nil
    if local_addr_list
      local_addr = local_addr_list.find {|local_ai| local_ai.afamily == ai.afamily }
      next unless local_addr
    end

    # 次の接続試行の開始時間
    next_connection_start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC) + CONNECTION_ATTEMPT_DELAY

    begin
      sock = Socket.new(ai.pfamily, ai.socktype, ai.protocol)
      sock.ipv6only! if ai.ipv6?
      sock.bind(local_addr) if local_addr

      addrinfos[sock] = ai # { <Socket> => <Addrinfo> }

      case sock.connect_nonblock(ai, exception: false)
      when 0
        ret = sock # ret = 接続できたソケット
        break
      when :wait_writable
        socket_list.push(sock) # sockがまだwritableではない場合はsocket_listに追加
      end
    rescue SystemCallError => ex
      last_error = ex
      sock&.close()
    end
  end

  # 接続済みのソケット、[未接続のSocket]、{ <未接続のSocket> => <接続対象のAddrinfo> }、エラー
  return ret, socket_list, addrinfos, last_error
end
```

```ruby
# socket_list -> 未接続のSocket
# addrinfos   -> { <未接続のSocket> => <接続対象のAddrinfo> }
# start_time  -> Socket.tcpの開始時間
def self.wait_connection(socket_list, addrinfos, connect_timeout, start_time)
  ret = nil
  timeout = nil # wait forever
  last_error = nil

  # 接続済みソケットがない、かつ未接続のSocketがある、かつタイムアウトしていない
  while !ret && !socket_list.empty? && timeout != 0
    # Socket.tcpの開始時間からconnect_timeout以上経過している場合はタイムアウトと判断
    if connect_timeout
      # set timeout for IO.select
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
      timeout = connect_timeout - elapsed
      timeout = 0 if timeout.negative? # returns immediately
    end

    begin
      # socket_list = [<未接続のソケット>] が [<接続済みソケット>] になったことを捕捉する
      _, writable_sockets, = IO.select(nil, socket_list, nil, timeout)
    rescue SystemCallError => ex
      last_error = ex
    end

    if writable_sockets && !writable_sockets.empty?
      # [<接続済みソケット>] が本当に接続済みかを確認するために find_connected_socket を呼ぶ
      # 接続済みソケット、エラー、接続失敗ソケットを取得
      ret, error, failed_sockets = find_connected_socket(writable_sockets, addrinfos)
      socket_list -= failed_sockets
      last_error = error if error
    end
  end

  # 接続済みソケット、エラー
  return ret, last_error
end
```

```ruby
def self.find_connected_socket(sockets, addrinfos)
  error = nil
  failed_sockets = []

  connected_socket = sockets.find do |socket|
    # check connection failure
    begin
      socket.connect_nonblock(addrinfos.fetch(socket))
      true
    rescue Errno::EISCONN # already connected
      error = nil
      true
    rescue => ex
      error = ex
      failed_sockets.push(socket)
      socket.close unless socket.closed?
      false
    end
  end

  return connected_socket, error, failed_sockets
end

private_class_method :find_connected_socket
```

```ruby
def self.pick_addrinfo(getaddrinfo_v6_done,
                       getaddrinfo_v4_done,
                       resolution_delay_done,
                       ai_list_v6,
                       ai_list_v4,
                       last_family)

  if getaddrinfo_v6_done && getaddrinfo_v4_done # IPv6 / IPv4いずれもgetaddrinfoが完了
    if last_family != Socket::AF_INET6 && !ai_list_v6.empty?
      return ai_list_v6.shift
    elsif !ai_list_v4.empty? # pick v4 address
      return ai_list_v4.shift
    end
  elsif getaddrinfo_v6_done && !ai_list_v6.empty? # IPv6 の getaddrinfoが完了
    return ai_list_v6.shift
  elsif getaddrinfo_v4_done && resolution_delay_done && !ai_list_v4.empty? # IPv4 の getaddrinfo が完了
    return ai_list_v4.shift
  end

  return nil # no available addrinfo for now
end
```

```ruby
# threads -> [getaddrinfo_v6_th, getaddrinfo_v4_th, timeout_th]
# ios     -> socket_list + [pipe_read, pipe_write] (socket_listがない場合はそれを除く)
def self.cleanup_socket_tcp(threads, ios)
  threads.each {|th| th&.exit }
  ios.each do |io|
    begin
      io.close if io && !io.closed?
    rescue
      # ignore error
    end
  end
end

private_class_method :cleanup_socket_tcp
```

## TL;DL
- アドレスファミリごとにスレッドを生成してそれぞれアドレス解決を試行
  - メインスレッドの変数 `ai_list_v6` / `ai_list_v4` にアドレスを書き込む
  - それぞれのスレッド内でアドレス解決を終えたら (Resolution Delayを終えたら) `pipe_write`に書き込む
  - 別のスレッドで`resolv_timeout`をカウントし、タイムアウトしたら`pipe_write`を閉じる
- メインスレッドで接続試行を実施
  - 各アドレス解決スレッドでのアドレス解決 (Resolution Delay) を待ち合わせる
  - `pipe_reads`がread可能になったら解決できたアドレスの中から接続試行するアドレスを選択
  - 接続開始前に次回接続試行開始可能終了時間を取得
  - 新しいソケットを生成し、ノンブロッキングモードで接続試行
    - 接続できたら当該ソケットを返す
    - 接続が`wait_writable`だったら当該ソケットを`socket_list`に入れて返す
  - getaddrinfoが完了していない場合、もしくは取得済みのアドレスがある限り上記の処理を続ける
    - 接続済みのソケットを取得できたら直ちにbreak
  - 接続できたソケット、`[<未接続のSocket>]`、`{ <未接続のSocket> => <接続対象のAddrinfo> }`、エラーを返す
- メインスレッドで接続試行に失敗した場合のリトライを実施
  - 未接続のSocketがwrite可能になったらノンブロッキングモードで接続試行
    - 接続できたら当該ソケットを返す
    - 接続が`wait_writable`だったら当該ソケットを`socket_list`に入れて返す
  - 接続済みソケットがない、かつ未接続のSocketがある、かつタイムアウトしていない限り上記の処理を続ける
    - 接続済みのソケットを取得できたら直ちにbreak
  - 接続済みのソケット、エラーを返す
- メインスレッドで後処理を行う
  - アドレス解決スレッドをexit
  - 接続ソケット以外のソケットをclose
