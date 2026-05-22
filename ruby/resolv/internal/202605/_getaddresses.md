# Resolv.getaddresses
- https://github.com/ruby/resolv/blob/master/lib/resolv.rb

```ruby
Resolv.getaddress("www.ruby-lang.org")
```

```ruby
# Resolv.getaddresses

def self.getaddresses(name)
  DefaultResolver.getaddresses(name) # DefaultResolver = self.new
  # => Resolv#initialize
  # => Resolv#getaddresses
end
```

### `Resolv#initialize`

```ruby
def initialize(resolvers = (arg_not_set = true; nil), use_ipv6: (keyword_not_set = true; nil))
  # resolversが明示的に指定されている場合arg_not_setはnil、そうでなければtrue
  # use_ipv6が明示的に指定されている場合keyword_not_setはnil、そうでなければtrue↲

  # resolversとuse_ipv6を両方渡した場合、use_ipv6は無視
  # use_ipv6は実際には使われていない。将来的にはデフォルトのDNSリゾルバを内部構築するフラグになる?
  if !keyword_not_set && !arg_not_set
    warn "Support for separate use_ipv6 keyword is deprecated,
          as it is ignored if an argument is provided.
          Do not provide a positional argument if using the use_ipv6 keyword argument.", uplevel: 1
  end

  # resolversをResolv.new(nameserver: ["8.8.8.8"])みたいにするとwhen Hashのブロックに入る

  @resolvers =
    case resolvers
    when Hash, nil
      config = DNS::Config.default_config_hash.merge(resolvers || {})
      # => DNS::Config.default_config_hash

      [Hosts.new, DNS.new(config)]
      # 前者はローカルで名前解決するためのもの、後者はDNSを利用するためのもの
      # => Hosts#initialize
      # => DNS#initialize
    else
      resolvers
    end
end
```

### DNS::Config.default_config_hash

```ruby
def Config.default_config_hash(filename="/etc/resolv.conf")
  if File.exist? filename
    Config.parse_resolv_conf(filename) # => Config.parse_resolv_conf
  elsif defined?(Win32::Resolv)
    search, nameserver = Win32::Resolv.get_resolv_info
    config_hash = {}
    config_hash[:nameserver] = nameserver if nameserver
    config_hash[:search] = [search].flatten if search
    config_hash
  else
    {}
  end
end

# Config.parse_resolv_conf

def Config.parse_resolv_conf(filename)
  nameserver = [] #  DNSサーバのIPアドレス
  search = nil
  ndots = 1

  File.open(filename, 'rb') {|f| # デフォルトではfilename = "/etc/resolv.conf"
    # e.g.
    #   nameserver 8.8.8.8
    #   nameserver 8.8.4.4
    #   search example.com local
    #   options ndots:5
    #   => { nameserver: ["8.8.8.8", "8.8.4.4"], search: ["example.com", "local"], ndots: 5 }

    f.each { |line|
      line.sub!(/[#;].*/, '')
      keyword, *args = line.split(/\s+/)

      next unless keyword

      case keyword
      when 'nameserver'
        nameserver.concat(args.each(&:freeze))
      when 'domain'
        next if args.empty?
        search = [args[0].freeze]
      when 'search'
        next if args.empty?
        search = args.each(&:freeze)
      when 'options'
        args.each {|arg|
          case arg
          when /\Andots:(\d+)\z/
            ndots = $1.to_i
          end
        }
      end
    }
  }

  return { :nameserver => nameserver.freeze, :search => search.freeze, :ndots => ndots.freeze }.freeze
end
```


### `Hosts#initialize`

```ruby
 def initialize(filename = DefaultFileName) # DefaultFileName = hosts || '/etc/hosts'
   @filename = filename
   @mutex = Thread::Mutex.new
   @initialized = nil
 end
```

### `DNS#initialize`

```ruby
def initialize(config_info=nil)
  @mutex = Thread::Mutex.new
  @config = Config.new(config_info) # => Config#initialize
  @initialized = nil
end
```

### `Config#initialize`

```ruby
def initialize(config_info=nil)
  @mutex = Thread::Mutex.new
  @config_info = config_info
  @initialized = nil
  @timeouts = nil
end
```

### `Resolv#getaddresses`

```ruby
def getaddresses(name)
  ret = []
  each_address(name) { |address| ret << address } # => Resolv#each_address
  return ret
end

# Resolv#each_address

def each_address(name)
  # AddressRegex = /(?:#{IPv4::Regex})|(?:#{IPv6::Regex})/
  # IPv4::RegexとIPv6::RegexはそれぞれIPv4クラス / IPv6クラスに自前実装がある
  if AddressRegex =~ name
    yield name # 渡された文字列がIPアドレスリテラルの場合、そのままブロックを実行して終了
    return
  end

  yielded = false

  @resolvers.each { |r| # @resolversは[Hosts.new, DNS.new(config)]もしくは任意のリゾルバオブジェクト
    r.each_address(name) { |address| # => Hosts#each_address or DNS#each_address or MDNS#each_address
      yield address.to_s # 取得したアドレスをわたしてブロックを実行
      yielded = true
    }
    return if yielded
  }
end
```

### `Hosts#each_address`

```ruby
def each_address(name, &proc)
  lazy_initialize # => Hosts#lazy_initialize 他のパブリックAPIも呼んでいる (なので@initializedで初期化を確認する)
  @name2addr[name]&.each(&proc) # @name2addr に収集したホスト名からアドレスを引き、ブロックを実行
end

# Hosts#lazy_initialize

def lazy_initialize # :nodoc:
  @mutex.synchronize {
    unless @initialized # Hosts#initializeの時点では @initialized = nil
      @name2addr = {} # { ホスト名 => [アドレス] } 形式のハッシュ
      @addr2name = {} # { アドレス => [ホスト名] } 形式のハッシュ

      File.open(@filename, 'rb') {|f| # Hosts#initializeの時点では @filename = hosts || '/etc/hosts'
        # /etc/hostsなどのローカルの設定ファイルを読み込んで@name2addrに書き込む
        # e.g.
        #   127.0.0.1   localhost localhost.local
        #   ::1         localhost
        #   ---
        #   addr      = "127.0.0.1"
        #   hostnames = ["localhost", "localhost.local"]
        #   @addr2name["127.0.0.1"]       = ["localhost", "localhost.local"]
        #   @name2addr["localhost"]       = ["127.0.0.1", "::1"]
        #   @name2addr["localhost.local"] = ["127.0.0.1"]

        f.each {|line|
          line.sub!(/#.*/, '')
          addr, *hostnames = line.split(/\s+/)

          next unless addr

          (@addr2name[addr] ||= []).concat(hostnames)
          hostnames.each { |hostname| (@name2addr[hostname] ||= []) << addr }
        }
      }

      @name2addr.each { |name, arr| arr.reverse! }
      @initialized = true
    end
  }
  self
end
```

### `DNS#each_address`

```ruby
def each_address(name)
  if use_ipv6? # => DNS#use_ipv6?
    each_resource(name, Resource::IN::AAAA) { |resource| # => DNS#each_resource WIP
      yield resource.address
    }
  end

  each_resource(name, Resource::IN::A) { |resource| # => DNS#each_resource
    yield resource.address
  }
end

# DNS#use_ipv6?

def use_ipv6? # :nodoc:
  unless @config.instance_variable_get(:@initialized) # @initialized = DNS.newの時点ではnil
    @config.lazy_initialize # => Config#lazy_initialize
  end

  use_ipv6 = @config.use_ipv6? # => Config#use_ipv6?

  # Config#use_ipv6?
  #
  #   def use_ipv6?
  #     @use_ipv6
  #   end

  if !use_ipv6.nil?
    return use_ipv6 # 明示的にIPv6を利用する意思がある場合はその意思を尊重してここでreturn
  end

  begin
    list = Socket.ip_address_list # ローカルの IP アドレスを取得
  rescue NotImplementedError
    return true
  end

  # 利用できるIPv6アドレスがあるかどうか == IPv6対応環境かどうか
  # (shioimm) TODO IPv6-only環境かどうかを確認する方法も必要そう
  list.any? {|a| a.ipv6? && !a.ipv6_loopback? && !a.ipv6_linklocal? }
end
```

### `Config#lazy_initialize`

```ruby
def lazy_initialize
  @mutex.synchronize {

    unless @initialized
      @nameserver_port = [] # 問い合わせ先フルリゾルバの一覧
      @use_ipv6 = nil       # IPv6を使うかどうか
      @search = nil         # DNS検索ドメインのリスト
      @ndots = 1            # 名前の中のドット数の閾値

      # config_hashの構築
      case @config_info
      when nil # デフォルト (/etc/resolv.confなどを利用する)
        config_hash = Config.default_config_hash
      when String # 明示的に指定したresolv.confなどを利用する
        config_hash = Config.parse_resolv_conf(@config_info)
      when Hash # 明示的に指定した設定値を利用する場合
        config_hash = @config_info.dup

        if String === config_hash[:nameserver]
          config_hash[:nameserver] = [config_hash[:nameserver]]
        end

        if String === config_hash[:search]
          config_hash[:search] = [config_hash[:search]]
        end
      else
        raise ArgumentError.new("invalid resolv configuration: #{@config_info.inspect}")
      end

      # --- config_hash から値を取り出す ---
      if config_hash.include? :nameserver
        @nameserver_port = config_hash[:nameserver].map {|ns| [ns, Port] }
      end

      if config_hash.include? :nameserver_port
        @nameserver_port = config_hash[:nameserver_port].map {|ns, port| [ns, (port || Port)] }
      end

      # e.g.
      #   Resolv::DNS.new(nameserver: ['8.8.8.8'], use_ipv6: true)
      # みたいな呼び出しをするとuse_ipv6? => trueになる
      if config_hash.include? :use_ipv6
        @use_ipv6 = config_hash[:use_ipv6]
      end

      @search = config_hash[:search] if config_hash.include? :search
      @ndots = config_hash[:ndots] if config_hash.include? :ndots
      @raise_timeout_errors = config_hash[:raise_timeout_errors]

      if @nameserver_port.empty?
        #  フルリゾルバが1つも設定されていない場合は0.0.0.0を利用
        @nameserver_port << ['0.0.0.0', Port]
      end

      # --- 検索ドメインの正規化 ---
      if @search
        @search = @search.map {|arg| Label.split(arg) }
      else
        hostname = Socket.gethostname
        if /\./ =~ hostname
          @search = [Label.split($')]
        else
          @search = [[]]
        end
      end

      # --- バリデーションチェック ---
      if !@nameserver_port.kind_of?(Array) ||
         @nameserver_port.any? { |ns_port|
            !(Array === ns_port) ||
            ns_port.length != 2
            !(String === ns_port[0]) ||
            !(Integer === ns_port[1])
         }
        raise ArgumentError.new("invalid nameserver config: #{@nameserver_port.inspect}")
      end

      if !@search.kind_of?(Array) ||
         !@search.all? {|ls| ls.all? {|l| Label::Str === l } }
        raise ArgumentError.new("invalid search config: #{@search.inspect}")
      end

      if !@ndots.kind_of?(Integer)
        raise ArgumentError.new("invalid ndots config: #{@ndots.inspect}")
      end

      @initialized = true
    end
  }
  self
end
```

### `DNS#each_resource`

```ruby
# name = ドメイン名
# typeclass = レコードの種類 (e.g. Resource::IN::AAAA)
def each_resource(name, typeclass, &proc)
  fetch_resource(name, typeclass) { |reply, reply_name| # => DNS#fetch_resource
    extract_resources(reply, reply_name, typeclass, &proc) # => DNS#extract_resources WIP
  }
end

# DNS#fetch_resource

def fetch_resource(name, typeclass)
  lazy_initialize # => DNS#lazy_initialize
  truncated = {}
  requesters = {}

  udp_requester =
    begin
      make_udp_requester # => DNS#make_udp_requester
      # DNS::Requester::ConnectedUDP もしくは DNS::Requester::UnconnectedUDPオブジェクトを作成してudp_requesterに格納
    rescue Errno::EACCES
      # fall back to TCP
    end

  senders = {}

  begin
    @config.resolv(name) do |candidate, tout, nameserver, port| # => Config#resolv
      msg = Message.new # => DNS::Message#initialize
      msg.rd = 1
      msg.add_question(candidate, typeclass) # => Message#add_question

      # Message#add_question
      #
      #   def add_question(name, typeclass)
      #     @question << [Name.create(name), typeclass] # => DNS::Name.create
      #   end

      # 初回の呼び出しでは実行されない
      # Config#resolv のcandidatesごと・timeoutsごとのeachが呼び出されるたびにtruncated / requestersに値が追加される
      requester = requesters.fetch([nameserver, port]) do
        if !truncated[candidate] && udp_requester
          udp_requester # DNS::Requester::ConnectedUDP もしくは DNS::Requester::UnconnectedUDPオブジェクト
        else
          # 権限エラーでUDPソケットの生成が失敗した場合もしくはUDPレスポンスにTCフラグが立っていた場合
          # make_tcp_requesterの返り値を requesters[[nameserver, port]] に保存
          requesters[[nameserver, port]] = make_tcp_requester(nameserver, port) # => DNS#make_tcp_requester
          # DNS::Requester::TCP オブジェクトを格納する
        end
      end

      # 呼び出し時にsendersに[candidate, requester, nameserver, port]のくみが存在しない場合のみ実行される
      unless sender = senders[[candidate, requester, nameserver, port]]
        sender = requester.sender(msg, candidate, nameserver, port) # 新しいsenderを生成
        # => DNS::Requester::ConnectedUDP#sender フルリゾルバが一つしかない場合 (接続することで安全性を高める)
        #    / DNS::Requester::UnconnectedUDP#sender フルリゾルバが複数ある場合
        #    / DNS::Requester::TCP#sender UDPのリクエスタが利用できない場合
        next if !sender
        senders[[candidate, requester, nameserver, port]] = sender
      end

      reply, reply_name = requester.request(sender, tout)
      # => DNS::Requester#request
      # Messageオブジェクト、sender.data (Nameオブジェクト)

      case reply.rcode # => Message attr_accessor :rcode (flag & 15 の値)
      when RCode::NoError
        if reply.tc == 1 and not Requester::TCP === requester
          # Retry via TCP:
          truncated[candidate] = true
          redo
        else
          yield(reply, reply_name) # => DNS#extract_resources WIP
        end
        return
      when RCode::NXDomain
        raise Config::NXDomain.new(reply_name.to_s)
      else
        raise Config::OtherResolvError.new(reply_name.to_s)
      end
    end
  ensure
    udp_requester&.close
    requesters.each_value { |requester| requester&.close }
  end
end

# DNS#make_udp_requester

def make_udp_requester # :nodoc:
  nameserver_port = @config.nameserver_port # => DNS#nameserver_port

  # DNS#nameserver_port
  #   def nameserver_port
  #     @nameserver_port
  #   end

  if nameserver_port.length == 1
    Requester::ConnectedUDP.new(*nameserver_port[0]) # => DNS::Requester::ConnectedUDP#initialize
  else
    Requester::UnconnectedUDP.new(*nameserver_port) # => DNS::Requester::UnconnectedUDP#initialize
  end
end

# DNS#make_tcp_requester

def make_tcp_requester(host, port) # :nodoc:
  return Requester::TCP.new(host, port) # => DNS::Requester::TCP#initialize
rescue Errno::ECONNREFUSED
  # Treat a refused TCP connection attempt to a nameserver like a timeout,
  # as Resolv::DNS::Config#resolv considers ResolvTimeout exceptions as a
  # hint to try the next nameserver:
  raise ResolvTimeout
end

# DNS#extract_resources WIP

def extract_resources(msg, name, typeclass) # :nodoc:
  if typeclass < Resource::ANY
    n0 = Name.create(name) # => DNS::Name.create 解決したいドメイン名をDNS::Nameオブジェクトにする
    msg.each_resource {|n, ttl, data| # => DNS::Message#each_resource
      yield data if n0 == n
    }
  end

  yielded = false
  n0 = Name.create(name)
  msg.each_resource {|n, ttl, data|
    if n0 == n
      case data
      when typeclass
        yield data
        yielded = true
      when Resource::CNAME
        n0 = data.name
      end
    end
  }
  return if yielded
  msg.each_resource {|n, ttl, data|
    if n0 == n
      case data
      when typeclass
        yield data
      end
    end
  }
end
```

### `DNS::Requester::ConnectedUDP#initialize`

```ruby
# class ConnectedUDP < Requester

 def initialize(host, port=Port)
   super() # => DNS::Requester#initialize
   @host = host
   @port = port
   @mutex = Thread::Mutex.new
   @initialized = false
 end
```

### `DNS::Requester::ConnectedUDP#sender`

```ruby
def sender(msg, data, host=@host, port=@port)
  # DNSサーバと接続確立
  lazy_initialize # => DNS::Requester::ConnectedUDP#lazy_initialize

  # 送信先の検証
  unless host == @host && port == @port
    raise RequestError.new("host/port don't match: #{host}:#{port}")
  end

  # 同じhost, portの組み合わせに対して、重複しない16ビットのトランザクションIDをランダムに払い出す
  id = DNS.allocate_request_id(@host, @port) # => DNS.allocate_request_id

  # MessageオブジェクトをDNSフォーマットのバイト列に変換する
  request = msg.encode # => Message#encode

  # バイト列の先頭2バイトを、allocate_request_idで払い出したトランザクションIDで上書き
  request[0,2] = [id].pack('n')

  return @senders[[nil,id]] = Sender.new(request, data, @socks[0])
  # => DNS::Requester::Sender#initialize
end

# DNS::Requester::ConnectedUDP#lazy_initialize

def lazy_initialize
  @mutex.synchronize {
    next if @initialized
    @initialized = true

    is_ipv6 = @host.index(':')
    sock = UDPSocket.new(is_ipv6 ? Socket::AF_INET6 : Socket::AF_INET)
    @socks = [sock]

    sock.do_not_reverse_lookup = true # => BasicSocket#do_not_reverse_lookup
    # アドレスからホスト名へ逆引きを行わない

    DNS.bind_random_port(sock, is_ipv6 ? "::" : "0.0.0.0") # => DNS.bind_random_port
    # UDPソケットにランダムなエフェメラルポートをバインドする
    # プラットフォームによって具体的な実装が異なる

    sock.connect(@host, @port) # => UDPSocket#connect
  }
  self
end
```

### `DNS::Requester::ConnectedUDP#recv_reply`

```ruby
def recv_reply(readable_socks)
  lazy_initialize # => DNS::Requester::ConnectedUDP#lazy_initialize

  reply = readable_socks[0].recv(UDPSize)
  return reply, nil
end
```

### `DNS::Requester::ConnectedUDP::Sender#send`

```ruby
# class Sender < Requester::Sender # :nodoc:
# attr_reader :data

def send
  raise "@sock is nil." if @sock.nil?
  @sock.send(@msg, 0)
end
```

### `DNS::Requester::UnconnectedUDP#initialize`

```ruby
# class UnconnectedUDP < Requester

def initialize(*nameserver_port)
  super() # => DNS::Requester#initialize
  @nameserver_port = nameserver_port
  @initialized = false
  @mutex = Thread::Mutex.new
end
```

### `DNS::Requester::UnconnectedUDP#sender`

```ruby
def sender(msg, data, host, port=Port)
  host = Addrinfo.ip(host).ip_address # フルリゾルバを名前解決してアドレスを取得

  lazy_initialize # => DNS::Requester::UnconnectedUDP#lazy_initialize

  sock = @socks_hash[host.index(':') ? "::" : "0.0.0.0"]
  return nil if !sock

  service = [host, port]

  # 同じhost, portの組み合わせに対して、重複しない16ビットのトランザクションIDをランダムに払い出す
  id = DNS.allocate_request_id(host, port) # => DNS.allocate_request_id

  # MessageオブジェクトをDNSフォーマットのバイト列に変換する
  request = msg.encode # => Message#encode

  # バイト列の先頭2バイトを、allocate_request_idで払い出したトランザクションIDで上書き
  request[0,2] = [id].pack('n')

  return @senders[[service, id]] = Sender.new(request, data, sock, host, port)
  # => DNS::Requester::UnconnectedUDP::Sender#initialize
end

# DNS::Requester::UnconnectedUDP#lazy_initialize

def lazy_initialize
  @mutex.synchronize {
    next if @initialized

    @initialized = true
    @socks_hash = {}
    @socks = []

    @nameserver_port.each {|host, port|
      if host.index(':') # IPv6 / IPv4の判別
        bind_host = "::"
        af = Socket::AF_INET6
      else
        bind_host = "0.0.0.0"
        af = Socket::AF_INET
      end

      # アドレスファミリごと1ソケットだけ生成する
      next if @socks_hash[bind_host]

      begin
        sock = UDPSocket.new(af)
      rescue Errno::EAFNOSUPPORT, Errno::EPROTONOSUPPORT
        next # The kernel doesn't support the address family.
      end

      @socks << sock
      @socks_hash[bind_host] = sock

      sock.do_not_reverse_lookup = true # => BasicSocket#do_not_reverse_lookup
      # アドレスからホスト名へ逆引きを行わない

      DNS.bind_random_port(sock, bind_host) # => DNS.bind_random_port
      # UDPソケットにランダムなエフェメラルポートをバインドする
      # プラットフォームによって具体的な実装が異なる
    }
  }
  self
end
```

### `DNS::Requester::UnconnectedUDP#recv_reply`

```ruby
def recv_reply(readable_socks)
  lazy_initialize # => DNS::Requester::UnconnectedUDP#recv_reply

  reply, from = readable_socks[0].recvfrom(UDPSize)
  return reply, [from[3],from[1]]
end
```

### `DNS::Requester::UnconnectedUDP::Sender#initialize`

```ruby
# class Sender < Requester::Sender # :nodoc:

def initialize(msg, data, sock, host, port)
  super(msg, data, sock) # => DNS::Requester::Sender#initialize
  @host = host
  @port = port
end

attr_reader :data
```

### `DNS::Requester::UnconnectedUDP::Sender#send`

```ruby
def send
  raise "@sock is nil." if @sock.nil?
  @sock.send(@msg, 0, @host, @port)
end
```

### `DNS::Requester::TCP#initialize`

```ruby
def initialize(host, port=Port)
  super() # => DNS::Requester#initialize
  @host = host
  @port = port
  sock = TCPSocket.new(@host, @port)
  @socks = [sock]
  @senders = {}
end
```

### `DNS::Requester::TCP#sender`

```ruby
def sender(msg, data, host=@host, port=@port)
  unless host == @host && port == @port
    raise RequestError.new("host/port don't match: #{host}:#{port}")
  end

  # 同じhost, portの組み合わせに対して、重複しない16ビットのトランザクションIDをランダムに払い出す
  id = DNS.allocate_request_id(@host, @port) # => DNS.allocate_request_id

  # MessageオブジェクトをDNSフォーマットのバイト列に変換する
  request = msg.encode # => Message#encode

  # バイト列の先頭2バイトを、メッセージの長さとallocate_request_idで払い出したトランザクションIDで上書き
  request[0,2] = [request.length, id].pack('nn')

  return @senders[[nil,id]] = Sender.new(request, data, @socks[0])
  # => DNS::Requester::Sender#initialize
end
```

### `DNS::Requester::TCP#recv_reply`

```ruby
def recv_reply(readable_socks)
  len_data = readable_socks[0].read(2)
  raise EOFError if len_data.nil? || len_data.bytesize != 2

  len = len_data.unpack('n')[0]
  reply = @socks[0].read(len)
  raise EOFError if reply.nil? || reply.bytesize != len

  return reply, nil
end
```

### `DNS::Requester::TCP::Sender#send`

```ruby
# class Sender < Requester::Sender # :nodoc:
# attr_reader :data

def send
  @sock.print(@msg)
  @sock.flush
end
```

### `DNS::Requester#initialize`

```ruby
def initialize
  @senders = {}
  @socks = nil
end
```

### `DNS::Requester#request`

```ruby
# - メッセージを送信する
# - メッセージを受信する
# - メッセージをデコードする
def request(sender, tout)
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  timelimit = start + tout

  begin
    sender.send
    # => DNS::Requester::ConnectedUDP::Sender#send メッセージを送信
    #    / DNS::Requester::UnconnectedUDP::Sender#send 宛先を指定してメッセージを送信
    #    / DNS::Requester::TCP::Sender#send メッセージをストリームとして送信
  rescue Errno::EHOSTUNREACH, # multi-homed IPv6 may generate this
         Errno::ENETUNREACH
    raise ResolvTimeout
  end

  while true
    before_select = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    timeout = timelimit - before_select

    if timeout <= 0
      raise ResolvTimeout
    end

    if @socks.size == 1
      select_result = @socks[0].wait_readable(timeout) ? [ @socks ] : nil
    else
      select_result = IO.select(@socks, nil, nil, timeout)
    end

    if !select_result
      after_select = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      next if after_select < timelimit
      raise ResolvTimeout
    end

    begin
      reply, from = recv_reply(select_result[0])
      # => DNS::Requester::ConnectedUDP#recv_reply メッセージを受信
      #    / DNS::Requester::UnconnectedUDP#recv_reply メッセージとリゾルバのアドレス情報を取得
      #    / DNS::Requester::TCP#recv_reply メッセージをストリームとして受信
    rescue Errno::ECONNREFUSED, # GNU/Linux, FreeBSD
           Errno::ECONNRESET, # Windows
           EOFError
      # No name server running on the server?
      # Don't wait anymore.
      raise ResolvTimeout
    end

    begin
      # DNSフォーマットのバイト列をMessageオブジェクトに変換
      msg = Message.decode(reply) # => DNS::Message.decode
    rescue DecodeError
      next # broken DNS message ignored
    end

    # 受信したレスポンスが自ら送信したリクエストに対する応答かどうかを確認、そうでなければ無視
    if sender == sender_for(from, msg) # => DNS::Requester#sender_for
      # DNS::Requester#sender_for
      #   def sender_for(addr, msg)
      #     @senders[[addr,msg.id]]
      #   end
      break
    else
      # unexpected DNS message ignored
    end
  end

  return msg, sender.data # => attr_reader :data
end
```

### `DNS::Requester::Sender#initialize`

```ruby
def initialize(msg, data, sock)
  @msg = msg
  @data = data
  @sock = sock
end
```

### `Config#resolv`

```ruby
def resolv(name)
  candidates = generate_candidates(name) # => Config#generate_candidates
  timeouts = @timeouts || generate_timeouts # => Config#generate_timeouts
  timeout_error = false

  begin
    candidates.each {|candidate|
      begin
        timeouts.each { |tout|
          @nameserver_port.each {|nameserver, port|
            begin
              # Config#resolvのブロックにcandidatesごとにtimeouts回
              # - candidate  = 実際にDNSへ問い合わせるドメイン名を表すDNS::Nameオブジェクト
              # - tout       = タイムアウト秒
              # - nameserver = フルリゾルバのIPアドレス
              # - port       = フルリゾルバのポート番号
              # を渡す
              yield candidate, tout, nameserver, port
            rescue ResolvTimeout
            end
          }
        }
        timeout_error = true

        raise ResolvError.new("DNS resolv timeout: #{name}")
      rescue NXDomain
      end
    }
  rescue ResolvError
    raise if @raise_timeout_errors && timeout_error
  end
end

# Config#generate_candidates

def generate_candidates(name)
  candidates = nil
  name = Name.create(name) # => DNS::Name.create 解決したいドメイン名をDNS::Nameオブジェクトにする

  if name.absolute? # => DNS::Name#absolute? デフォルトでtrue
    # DNS::Name#absolute?
    #
    #   def absolute?
    #     return @absolute
    #   end
    candidates = [name] # FQDNの場合はそのまま名前解決を行う候補として扱う
  else
    if @ndots <= name.length - 1
      candidates = [Name.new(name.to_a)] # @ndot <= .の数 の場合はそのまま名前解決を行う候補として扱う
    else
      candidates = [] # @ndot > .の数 の場合は検索ドメインを試すため候補リストを空に初期化
    end

    # @searchの各ドメインを名前の末尾に連結した候補を追加
    candidates.concat(@search.map { |domain| Name.new(name.to_a + domain) }) # => DNS::Name#initialize

    # 名前に.を付けてFQDNにしたものを最後の候補として追加
    fname = Name.create("#{name}.") # => DNS::Name.create

    if !candidates.include?(fname)
      candidates << fname
    end
  end
  return candidates
end

# Config#generate_timeouts

InitialTimeout = 5

def generate_timeouts
  ts = [InitialTimeout]
  ts << ts[-1] * 2 / @nameserver_port.length
  ts << ts[-1] * 2
  ts << ts[-1] * 2
  return ts
end
```

### `DNS::Name.create`

```ruby
def self.create(arg)
  case arg
  when Name
    return arg
  when String
    labels = Label.split(arg) # => DNS::Label.split

    # Label.split ドメイン名を.で分割し、各部分をLabel::Strオブジェクトの配列にする
    #
    #   def self.split(arg)
    #     labels = []
    #     arg.scan(/[^\.]+/) { labels << Str.new($&) } # => DNS::Label::Str#initialize
    #     return labels
    #   end

    # Label::Str#initialize
    #
    #   def initialize(string)
    #     @string = string
    #     @downcase = string.b.downcase
    #   end

    return Name.new(labels, /\.\z/ =~ arg ? true : false) # => DNS::Name#initialize
  else
    raise ArgumentError.new("cannot interpret as DNS name: #{arg.inspect}")
  end
end

# DNS::Name#initialize

def initialize(labels, absolute=true) # :nodoc:
  labels = labels.map {|label|
    case label
    when String then Label::Str.new(label) # => DNS::Label::Str#initialize
    when Label::Str then label
    else
      raise ArgumentError, "unexpected label: #{label.inspect}"
    end
  }

  @labels = labels
  @absolute = absolute
end
```

### `DNS::Message#initialize`

```ruby
@@identifier = -1

# @id = どのレスポンスがどのリクエストに対応するかを識別するためのトランザクションID
# @@identifier をインクリメントし、& 0xffff で16ビット (0〜65535) の範囲に収める

def initialize(id = (@@identifier += 1) & 0xffff)
  @id = id
  @qr = 0
  @opcode = 0
  @aa = 0
  @tc = 0
  @rd = 0 # recursion desired
  @ra = 0 # recursion available
  @rcode = 0
  @question = []
  @answer = []
  @authority = []
  @additional = []
end

attr_accessor :id, :qr, :opcode, :aa, :tc, :rd, :ra, :rcode
attr_reader :question, :answer, :authority, :additional
```

### `DNS::Message.decode`

```ruby
def Message.decode(m)
  # ID = 0で空のMessageオブジェクトを作成
  o = Message.new(0) # => DNS::Message#initialize

  MessageDecoder.new(m) {|msg| # => DNS::Message::MessageDecoder#initialize
    # ヘッダを取得
    # ID, Flag, Question Count, Answer Count, Name Server Count, Additional Record Count
    id, flag, qdcount, ancount, nscount, arcount = msg.get_unpack('nnnnnn')
    # => DNS::Message::MessageDecoder#get_unpack
    # nnnnnn: 2 bytes * 6 = 12 bytes

    o.id = id
    o.tc = (flag >> 9) & 1 # flagはビット演算で各フィールドを取り出す
    o.rcode = flag & 15

    # TC = 1の場合はTCPによる再試行を行うためここでreturn
    return o unless o.tc.zero?

    o.qr = (flag >> 15) & 1      # # 0 = クエリ / 1 = レスポンス
    o.opcode = (flag >> 11) & 15 # OPcodes
    o.aa = (flag >> 10) & 1      # Authoritative Answer 権威のある回答
    o.rd = (flag >> 8) & 1       # Recursion Desired 再帰問い合わせ要求
    o.ra = (flag >> 7) & 1       # Recursion Available 再帰問い合わせが可能

    # Questionセクションのエントリを取得
    (1..qdcount).each {
      name, typeclass = msg.get_question # => DNS::Message::MessageDecoder#get_question
      o.add_question(name, typeclass) # => DNS::Message::MessageDecoder#add_question
    }

    # Answerセクションのリソースレコードを取得
    (1..ancount).each {
      name, ttl, data = msg.get_rr # => DNS::Message::MessageDecoder#get_rr
      o.add_answer(name, ttl, data) # => DNS::Message::MessageDecoder#add_answer
    }

    # Authorityセクションのリソースレコード (NSレコード / SOAレコード) を取得
    (1..nscount).each {
      name, ttl, data = msg.get_rr # => DNS::Message::MessageDecoder#get_rr
      o.add_authority(name, ttl, data) # => DNS::Message::MessageDecoder#add_authority
    }

    #  Additionalセクションのリソースレコードを取得
    (1..arcount).each {
      name, ttl, data = msg.get_rr # => DNS::Message::MessageDecoder#get_rr
      o.add_additional(name, ttl, data) # => DNS::Message::MessageDecoder#add_additional
    }
  }

  return o
end
```

### `DNS::Message::MessageDecoder#initialize`

```ruby
def initialize(data)
  @data = data
  @index = 0
  @limit = data.bytesize
  yield self
end
```

### `DNS::Message::MessageDecoder#get_unpack`

```ruby
def get_unpack(template)
  len = 0

  # 読み取りバイト数の計算
  template.each_byte {|byte|
    byte = "%c" % byte
    case byte
    when ?c, ?C then len += 1 # 符号あり/なし 1バイト整数
    when ?n     then len += 2 # ビッグエンディアン 2バイト整数
    when ?N     then len += 4 # ビッグエンディアン 4バイト整数
    else
      raise StandardError.new("unsupported template: '#{byte.chr}' in '#{template}'")
    end
  }

  raise DecodeError.new("limit exceeded") if @limit < @index + len

  # @index = バイト列内の現在位置
  arr = @data.unpack("@#{@index}#{template}") # 現在位置からtemplateに従って値を取得
  @index += len # 読み取った分オフセットを進める
  return arr
end
```

### `DNS::Message::MessageDecoder#get_question`

```ruby
# DNS ワイヤーフォーマットのQuestion セクションから1エントリを読み取り、
# [ドメイン名を表すNameオブジェクト, リソースレコードの種類を表すResourceのサブクラス] の形式で返す
def get_question
  name = self.get_name # => DNS::Message::MessageDecoder#get_name

  # Questionセクションのドメイン名の直後にある4バイトを取り出す
  # type  = クエリタイプ
  # klass = クエリクラス
  type, klass = self.get_unpack("nn")

  return name, Resource.get_class(type, klass) # => DNS::Resource.get_class
end

# DNS::Message::MessageDecoder#get_name
# DNSフォーマットのバイト列からドメイン名を読み取り、Nameオブジェクトとして返す

def get_name
  return Name.new(self.get_labels) # => DNS::Message::MessageDecoder#get_labels
end

# DNS::Message::MessageDecoder#get_labels
# ラベルの配列を返す

def get_labels
  prev_index = @index
  save_index = nil
  d = []
  size = -1

  while true
    raise DecodeError.new("limit exceeded") if @limit <= @index

    case @data.getbyte(@index) # @data = DNSレスポンスのバイト列
    when 0 # ドメイン名の終わりを示す0x00
      @index += 1
      if save_index
        @index = save_index
      end
      return d

    when 192..255 # 同じメッセージ内に複数出現する同じドメイン名の最初の位置を示すポインタ
      idx = self.get_unpack('n')[0] & 0x3fff

      if prev_index <= idx
        raise DecodeError.new("non-backward name pointer")
      end

      prev_index = idx
      if !save_index
        save_index = @index
      end
      @index = idx
    else # 通常のラベル
      l = self.get_label # => DNS::Message::MessageDecoder#get_label
      d << l
      size += 1 + l.string.bytesize
      raise DecodeError.new("name label data exceed 255 octets") if size > 255
    end
  end
end

# DNS::Message::MessageDecoder#get_label
# ラベルとして取得した文字列をLabel::Strオブジェクトとして返す

def get_label
  return Label::Str.new(self.get_string) # => DNS::Message::MessageDecoder#get_string
end

# DNS::Message::MessageDecoder#get_string
# 現在位置のバイトを長さとして読み、その分の文字列を取り出して返す

def get_string
  raise DecodeError.new("limit exceeded") if @limit <= @index

  len = @data.getbyte(@index)
  raise DecodeError.new("limit exceeded") if @limit < @index + 1 + len

  d = @data.byteslice(@index + 1, len)
  @index += 1 + len
  return d
end
```

### `DNS::Message::MessageDecoder#get_string_list`

```ruby
# @limitに達するまでDNS::Message::MessageDecoder#get_stringを繰り返し呼ぶ

def get_string_list
  strings = []

  while @index < @limit
    strings << self.get_string
  end

  strings
end
```

### `DNS::Message::MessageDecoder#add_question`

```ruby
def add_question(name, typeclass)
  @question << [Name.create(name), typeclass]
end
```

### `DNS::Message::MessageDecoder#get_rr`

```ruby
def get_rr
  name = self.get_name # => DNS::Message::MessageDecoder#get_name

  # Answer/Authority/Additionalセクションのドメイン名の直後にある8バイトを取り出す
  # type  = クエリタイプ
  # klass = クエリクラス
  # ttl   = TTL
  type, klass, ttl = self.get_unpack('nnN')

  # タイプ値とクラス値の数値に対応するリソースレコードの種類を取得する
  typeclass = Resource.get_class(type, klass) # => DNS::Resource.get_class

  res = self.get_length16 do # => DNS::Message::MessageDecoderget_length16
    begin
      typeclass.decode_rdata self
      # => DNS::Query.decode_rdata (DecodeError)
      #    / DNS::Resource.decode_rdata (NotImplementedError)
      #    / DNS::Resource::Generic.decode_rdata            未知のRR
      #    / DNS::Resource::DomainName.decode_rdata         NS / CNAME / PTR (を表すクラスのスーパークラス)
      #    / DNS::Resource::SOA.decode_rdata                SOA
      #    / DNS::Resource::HINFO.decode_rdata              HINFO ホストのハードウェアとOSの情報を表すRR
      #    / DNS::Resource::MINFO.decode_rdata              MINFO メーリングリストなどのメール情報を表すRR
      #    / DNS::Resource::MX.decode_rdata                 MX
      #    / DNS::Resource::TXT.decode_rdata                TXT
      #    / DNS::Resource::LOC.decode_rdata                LOC ホストの地理的位置情報を格納するRR
      #    / DNS::Resource::CAA.decode_rdata                CAA SSL/TLS証明書を発行できる認証局を指定するRR
      #    / DNS::Resource::IN::A.decode_rdata              A
      #    / DNS::Resource::IN::AAAA.decode_rdata           AAAA
      #    / DNS::Resource::IN::WKS.decode_rdata            WKS どのプロトコル・ポートでサービスを提供しているか
      #    / DNS::Resource::IN::SRV.decode_rdata            SRV
      #    / DNS::Resource::IN::ServiceBinding.decode_rdata SVCB / HTTPS (の共通実装)
    rescue => e
      raise DecodeError, e.message, e.backtrace
    end
  end

  # リソースレコードを表すオブジェクトにttlを設定
  res.instance_variable_set :@ttl, ttl

  return name, ttl, res
end

# DNS::Message::MessageDecoder#get_length16

def get_length16
  # 2バイト読んでRDLENGTH = リソースデータの長さを取得
  len, = self.get_unpack('n') # => DNS::Message::MessageDecoder#get_unpack
  save_limit = @limit
  @limit = @index + len

  # ブロックを実行してリソースデータをデコード
  d = yield(len)

  if @index < @limit
    raise DecodeError.new("junk exists")
  elsif @limit < @index
    raise DecodeError.new("limit exceeded")
  end

  @limit = save_limit

  # デコードしたデータを返す
  return d
end
```

### `DNS::Message::MessageDecoder#add_answer`

```ruby
def add_answer(name, ttl, data)
  @answer << [Name.create(name), ttl, data]
end
```

### `DNS::Message::MessageDecoder#add_authority`

```ruby
def add_authority(name, ttl, data)
  @authority << [Name.create(name), ttl, data]
end
```

### `DNS::Message::MessageDecoder#add_additional`

```ruby
def add_additional(name, ttl, data)
  @additional << [Name.create(name), ttl, data]
end
```

### `DNS::Message::MessageDecoder#get_bytes`

```ruby
# 指定バイト数を読み込んで返す

def get_bytes(len = @limit - @index)
  raise DecodeError.new("limit exceeded") if @limit < @index + len

  d = @data.byteslice(@index, len)
  @index += len

  return d
end
```

### `DNS::Message#each_resource`

```ruby
def each_resource
  each_answer { |name, ttl, data| yield name, ttl, data} # => DNS::Message#each_answer
  each_authority { |name, ttl, data| yield name, ttl, data} # => DNS::Message#each_authority
  each_additional { |name, ttl, data| yield name, ttl, data} # => DNS::Message#each_additional
end

# DNS::Message#each_answer

def each_answer
  @answer.each { |name, ttl, data|
    yield name, ttl, data
  }
end

# DNS::Message#each_authority

def add_authority(name, ttl, data)
  @authority << [Name.create(name), ttl, data]
end

# DNS::Message#each_additional

def each_additional
  @additional.each { |name, ttl, data|
    yield name, ttl, data
  }
end
```

### `DNS::Resource.get_class`

```ruby
# タイプ値とクラス値の数値に対応するリソースレコードの種類を取得する

def self.get_class(type_value, class_value) # :nodoc:
  cache = :"Type#{type_value}_Class#{class_value}"

  # 既知のレコードの種類 (e.g. IN::A, IN:AAAA, IN::SRV, ...) は、各クラス定義時にClassHashに保存されている
  # 未知のレコードの場合はGeneric.createする
  return (const_defined?(cache) && const_get(cache)) ||
         Generic.create(type_value, class_value) # => DNS::Resource::Generic.create
end
```

### `DNS::Resource::Generic.create`

```ruby
def self.create(type_value, class_value) # :nodoc:
  c = Class.new(Generic) # DNS::Resource::Genericのサブクラスを定義
  c.const_set(:TypeValue, type_value) # DNS::Resource::Generic::TypeValue = タイプ値
  c.const_set(:ClassValue, class_value) # DNS::Resource::Generic::ClassValue = クラス値

  # DNS::Resource::Generic::Type#{type_value}_Class#{class_value} = c
  Generic.const_set("Type#{type_value}_Class#{class_value}", c)

  ClassHash[[type_value, class_value]] = c # => DNS::Resource::ClassHash

  # DNS::Resource::ClassHash
  #
  #   ClassHash = Module.new do
  #     module_function
  #
  #     def []=(type_class_value, klass)
  #       type_value, class_value = type_class_value
  #       Resource.const_set(:"Type#{type_value}_Class#{class_value}", klass)
  #     end
  #   end

  return c
end
```

### `DNS::Resource::Generic.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  return self.new(msg.get_bytes)
  # => DNS::Message::MessageDecoder#get_bytes
  # => DNS::Resource::Generic#initialize
end

# DNS::Resource::Generic#initialize

def initialize(value)
  @value = value
end
```

### `DNS::Resource::DomainName.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  return self.new(msg.get_name)
  # => DNS::Message::MessageDecoder#get_name
  # => DNS::Resource::DomainName#initialize
end

# DNS::Resource::DomainName#initialize

def initialize(name)
  @name = name
end
```

### `DNS::Resource::SOA.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  # このゾーンのプライマリ権威サーバのドメイン名を取得
  mname = msg.get_name # => DNS::Message::MessageDecoder#get_name

  # このゾーンの管理者のメールアドレスを取得
  rname = msg.get_name # => DNS::Message::MessageDecoder#get_name

  # ビッグエンディアン4バイト整数 * 5
  # serial  = ゾーンファイルのバージョン番号
  # refresh = セカンダリサーバからプライマリへのゾーン更新を確認する間隔
  # retry_  = refreshに失敗した場合の再試行間隔
  # expire  = プライマリに接続できない状態が続いた場合、セカンダリサーバがゾーンデータを破棄するまでの時間
  # minimum = ネガティブキャッシュのTTL
  serial, refresh, retry_, expire, minimum = msg.get_unpack('NNNNN') # => DNS::Message::MessageDecoder#get_unpack

  return self.new(mname, rname, serial, refresh, retry_, expire, minimum)
  # => DNS::Resource::SOA#initialize
end

# DNS::Resource::SOA#initialize

def initialize(mname, rname, serial, refresh, retry_, expire, minimum)
  @mname = mname
  @rname = rname
  @serial = serial
  @refresh = refresh
  @retry = retry_
  @expire = expire
  @minimum = minimum
end
```

### `DNS::Resource::HINFO.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  # ホストのCPU情報を取得
  cpu = msg.get_string # => DNS::Message::MessageDecoder#get_string

  # ホストのOSを取得
  os = msg.get_string # => DNS::Message::MessageDecoder#get_string

  return self.new(cpu, os)
  # => DNS::Resource::HINFO#initialize
end

# DNS::Resource::HINFO#initialize

def initialize(cpu, os)
  @cpu = cpu
  @os = os
end
```

### `DNS::Resource::MINFO.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  # メーリングリストの管理者メールアドレスを取得
  rmailbx = msg.get_string # => DNS::Message::MessageDecoder#get_string

  # エラーメッセージの送信先メールアドレスを取得
  emailbx = msg.get_string # => DNS::Message::MessageDecoder#get_string

  return self.new(rmailbx, emailbx)
  # => DNS::Resource::MINFO#initialize
end

# DNS::Resource::MINFO#initialize

def initialize(rmailbx, emailbx)
  @rmailbx = rmailbx
  @emailbx = emailbx
end
```

### `DNS::Resource::MX.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  # 優先度を取得
  preference, = msg.get_unpack('n') # => DNS::Message::MessageDecoder#get_unpack
  # メールを受け取るサーバーのドメイン名を取得
  exchange = msg.get_name # => DNS::Message::MessageDecoder#get_name

  return self.new(preference, exchange)
  # => DNS::Resource::MX#initialize
end

# DNS::Resource::MX.decode_rdata

def initialize(preference, exchange)
  @preference = preference
  @exchange = exchange
end
```

### `DNS::Resource::TXT.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  strings = msg.get_string_list # => DNS::Message::MessageDecoder#get_string_list
  return self.new(*strings)
  # => DNS::Resource::TXT#initialize
end

# DNS::Resource::TXT#initialize

def initialize(first_string, *rest_strings)
  @strings = [first_string, *rest_strings]
end
```

### `DNS::Resource::LOC.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  version    = msg.get_bytes(1) # => DNS::Message::MessageDecoder#get_bytes
  ssize      = msg.get_bytes(1) # => DNS::Message::MessageDecoder#get_bytes
  hprecision = msg.get_bytes(1) # => DNS::Message::MessageDecoder#get_bytes
  vprecision = msg.get_bytes(1) # => DNS::Message::MessageDecoder#get_bytes
  latitude   = msg.get_bytes(4) # => DNS::Message::MessageDecoder#get_bytes
  longitude  = msg.get_bytes(4) # => DNS::Message::MessageDecoder#get_bytes
  altitude   = msg.get_bytes(4) # => DNS::Message::MessageDecoder#get_bytes

  return self.new(
    version,                                 # バージョン
    Resolv::LOC::Size.new(ssize),            # 対象物の球面サイズm
    Resolv::LOC::Size.new(hprecision),       # 水平精度m
    Resolv::LOC::Size.new(vprecision),       # 垂直精度m
    Resolv::LOC::Coord.new(latitude,"lat"),  # 緯度
    Resolv::LOC::Coord.new(longitude,"lon"), # 経度
    Resolv::LOC::Alt.new(altitude)           # 高度
  )
  # => DNS::Resource::LOC#initialize
end

# DNS::Resource::LOC#initialize

def initialize(version, ssize, hprecision, vprecision, latitude, longitude, altitude)
  @version    = version
  @ssize      = Resolv::LOC::Size.create(ssize)      # => Resolv::LOC::Size.create
  @hprecision = Resolv::LOC::Size.create(hprecision) # => Resolv::LOC::Size.create
  @vprecision = Resolv::LOC::Size.create(vprecision) # => Resolv::LOC::Size.create
  @latitude   = Resolv::LOC::Coord.create(latitude)  # => Resolv::LOC::Coord.create
  @longitude  = Resolv::LOC::Coord.create(longitude) # => Resolv::LOC::Coord.create
  @altitude   = Resolv::LOC::Alt.create(altitude)    # => Resolv::LOC::Alt.create
end
```

### `DNS::Resource::CAA.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  # フラグを取得
  flags, = msg.get_unpack('C') # => DNS::Message::MessageDecoder#get_unpack

  # プロパティの種別を表すタグを取得
  tag = msg.get_string # => DNS::Message::MessageDecoder#get_string

  # タグに対応する値を取得
  value = msg.get_bytes # => DNS::Message::MessageDecoder#get_bytes

  self.new(flags, tag, value)
  # => DNS::Resource::CAA#initialize
end

# DNS::Resource::CAA#initialize

def initialize(flags, tag, value)
  unless (0..255) === flags
    raise ArgumentError.new('flags must be an Integer between 0 and 255')
  end

  unless (1..15) === tag.bytesize
    raise ArgumentError.new('length of tag must be between 1 and 15')
  end

  @flags = flags
  @tag = tag
  @value = value
end
```

### `DNS::Resource::IN::A.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  # IPv4アドレスの4バイトを取得
  bytes = msg.get_bytes(4) # => DNS::Message::MessageDecoder#get_bytes

  # IPv4アドレスを表すオブジェクトを作成
  address = IPv4.new(bytes) # => IPv4#initialize

  return self.new(address)
  # => DNS::Resource::IN::A#initialize
end

# DNS::Resource::IN::A#initialize

def initialize(address)
  @address = IPv4.create(address) # => IPv4.create
end
```

### `DNS::Resource::IN::AAAA.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
　# IPv6アドレスの16バイトを取得
  bytes = msg.get_bytes(16) # => DNS::Message::MessageDecoder#get_bytes

  # IPv6アドレスを表すオブジェクトを作成
  address = IPv6.new(bytes) # => IPv6#initialize

  return self.new(address)
  # => DNS::Resource::IN::AAAA#initialize
end

# DNS::Resource::IN::AAAA#initialize

def initialize(address)
  @address = IPv6.create(address) # => IPv6.create
end
```

### `DNS::Resource::IN::WKS.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  # IPv4アドレスの4バイトを取得
  bytes = msg.get_bytes(4) # => DNS::Message::MessageDecoder#get_bytes

  # IPv4アドレスを表すオブジェクトを作成
  address = IPv4.new(bytes) # => IPv4#initialize

  # プロトコル番号を取得
  protocol, = msg.get_unpack("n") # => DNS::Message::MessageDecoder#get_unpack

  # ポート番号に対応するビットマップを取得
  bitmap = msg.get_bytes # => DNS::Message::MessageDecoder#get_bytes

  return self.new(address, protocol, bitmap)
  # => DNS::Resource::IN::WKS#initialize
end

# DNS::Resource::IN::WKS#initialize

def initialize(address, protocol, bitmap)
  @address = IPv4.create(address) # => IPv4.create
  @protocol = protocol
  @bitmap = bitmap
end
```

### `DNS::Resource::IN::SRV.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  # 優先度を取得
  priority, = msg.get_unpack("n") # => DNS::Message::MessageDecoder#get_unpack

  # 重みを取得
  weight, = msg.get_unpack("n") # => DNS::Message::MessageDecoder#get_unpack

  # ポート番号を取得
  port, = msg.get_unpack("n") # => DNS::Message::MessageDecoder#get_unpack

  # ターゲットのドメイン名を取得
  target = msg.get_name # => DNS::Message::MessageDecoder#get_name

  return self.new(priority, weight, port, target)
  # => DNS::Resource::IN::SRV#initialize
end

# DNS::Resource::IN::SRV#initialize

def initialize(priority, weight, port, target)
  @priority = priority.to_int
  @weight = weight.to_int
  @port = port.to_int
  @target = Name.create(target) # => DNS::Name.create
end
```

### `DNS::Resource::IN::ServiceBinding.decode_rdata`

```ruby
def self.decode_rdata(msg) # :nodoc:
  # 優先度を取得
  priority, = msg.get_unpack("n") # => DNS::Message::MessageDecoder#get_unpack

  # サービスが動作するホストのドメイン名を取得
  target = msg.get_name # => DNS::Message::MessageDecoder#get_name

  # HTTPS/SVCB 固有のサービスパラメータを読み取ってSvcParamsオブジェクトとして生成
  params = SvcParams.decode(msg) # => DNS::SvcParams.decode

  return self.new(priority, target, params)
  # => DNS::Resource::IN::ServiceBinding#initialize
end

def initialize(priority, target, params = [])
  @priority = priority.to_int
  @target = Name.create(target) # => DNS::Name.create
  @params = SvcParams.new(params) # => DNS::SvcParams#initialize
end
```

### `IPv4#initialize`

```ruby
def initialize(address) # :nodoc:
  unless address.kind_of?(String)
    raise ArgumentError, 'IPv4 address must be a string'
  end

  unless address.length == 4
    raise ArgumentError, "IPv4 address expects 4 bytes but #{address.length} bytes"
  end

  @address = address
end
```

### `IPv4.create`

```ruby
def self.create(arg)
  case arg
  when IPv4
    return arg
  when Regex
    if (0..255) === (a = $1.to_i) &&
       (0..255) === (b = $2.to_i) &&
       (0..255) === (c = $3.to_i) &&
       (0..255) === (d = $4.to_i)
      return self.new([a, b, c, d].pack("CCCC")) # => IPv4#initialize
    else
      raise ArgumentError.new("IPv4 address with invalid value: " + arg)
    end
  else
    raise ArgumentError.new("cannot interpret as IPv4 address: #{arg.inspect}")
  end
end
```

### `IPv6#initialize`

```ruby
def initialize(address) # :nodoc:
  unless address.kind_of?(String) && address.length == 16
    raise ArgumentError.new('IPv6 address must be 16 bytes')
  end

  @address = address
end
```

### `IPv6.create`

```ruby
def self.create(arg)
  case arg
  when IPv6 then return arg
  when String
    address = ''.b

    if Regex_8Hex =~ arg
      arg.scan(/[0-9A-Fa-f]+/) {|hex| address << [hex.hex].pack('n')}
    elsif Regex_CompressedHex =~ arg
      prefix = $1
      suffix = $2
      a1 = ''.b
      a2 = ''.b
      prefix.scan(/[0-9A-Fa-f]+/) {|hex| a1 << [hex.hex].pack('n')}
      suffix.scan(/[0-9A-Fa-f]+/) {|hex| a2 << [hex.hex].pack('n')}
      omitlen = 16 - a1.length - a2.length
      address << a1 << "\0" * omitlen << a2
    elsif Regex_6Hex4Dec =~ arg
      prefix, a, b, c, d = $1, $2.to_i, $3.to_i, $4.to_i, $5.to_i

      if (0..255) === a && (0..255) === b && (0..255) === c && (0..255) === d
        prefix.scan(/[0-9A-Fa-f]+/) {|hex| address << [hex.hex].pack('n')}
        address << [a, b, c, d].pack('CCCC')
      else
        raise ArgumentError.new("not numeric IPv6 address: " + arg)
      end
    elsif Regex_CompressedHex4Dec =~ arg
      prefix, suffix, a, b, c, d = $1, $2, $3.to_i, $4.to_i, $5.to_i, $6.to_i

      if (0..255) === a && (0..255) === b && (0..255) === c && (0..255) === d
        a1 = ''.b
        a2 = ''.b
        prefix.scan(/[0-9A-Fa-f]+/) {|hex| a1 << [hex.hex].pack('n')}
        suffix.scan(/[0-9A-Fa-f]+/) {|hex| a2 << [hex.hex].pack('n')}
        omitlen = 12 - a1.length - a2.length
        address << a1 << "\0" * omitlen << a2 << [a, b, c, d].pack('CCCC')
      else
        raise ArgumentError.new("not numeric IPv6 address: " + arg)
      end
    else
      raise ArgumentError.new("not numeric IPv6 address: " + arg)
    end

    return IPv6.new(address) # => IPv6#initialize
  else
    raise ArgumentError.new("cannot interpret as IPv6 address: #{arg.inspect}")
  end
end
```

### `DNS::SvcParams.decode`

```ruby
ClassHash = Hash.new do |h, key| # :nodoc:
  case key
  when Integer              then Generic.create(key) # => DNS::Resource::Generic.create
  when /\Akey(?<key>\d+)\z/ then Generic.create(key.to_int) # => DNS::Resource::Generic.create
  when Symbol               then raise KeyError, "unknown key #{key}"
  else
    raise TypeError, 'key must be either String or Symbol'
  end
end

def self.decode(msg) # :nodoc:
  # @limit に達するまでブロックを繰り返し実行し、結果を配列として返す
  params = msg.get_list do # => DNS::Message::MessageDecoder#get_list
    # 2バイトを読んでパラメータキーの番号を取得
    key, = msg.get_unpack('n') # => DNS::Message::MessageDecoder#get_unpack

    # 2バイトの長さフィールドを読み、パラメータ値のデコードをその範囲内に制限
    msg.get_length16 do # => # => DNS::Message::MessageDecoder#get_length16
      # キー番号に対応するSvcParamサブクラスを取得
      value = SvcParam::ClassHash[key] # => DNS::SvcParam::ClassHash#[]

      # そのクラスの.decodeでパラメータ値をデコード
      value.decode(msg)
      # => DNS::SvcParam::Mandatory.decode       mandatoryパラメータ クライアントがサポートするべきパラメータ群
      #    / DNS::SvcParam::ALPN.decode          alpnパラメータ サーバーが対応するプロトコル群
      #    / DNS::SvcParam::NoDefaultALPN.decode no-default-alpnパラメータ デフォルトプロトコルへフォールバック禁止
      #    / DNS::SvcParam::Port.decode          portパラメータ クライアントが接続するべきポート番号
      #    / DNS::SvcParam::IPv4Hint.decode WIP
      #    / DNS::SvcParam::IPv6Hint.decode WIP
      #    / DNS::SvcParam::DoHPath.decode WIP
      #    / DNS::SvcParam::Generic.decode WIP
    end
  end

  return self.new(params)
  # => DNS::SvcParams#initialize
end
```

### `DNS::SvcParams#initialize`

```ruby
def initialize(params = [])
  @params = {}

  params.each do |param|
    add param # => DNS::SvcParams#add
  end
end

# DNS::SvcParams#add

def add(param)
  @params[param.class.key_number] = param
end
```

### `DNS::SvcParam::Mandatory.decode`

```ruby
# class Mandatory < SvcParam

def self.decode(msg) # :nodoc:
  # @limitに達するまで2バイトずつ読み取り、必須パラメータキーの番号の配列を取得
  keys = msg.get_list { # => DNS::Message::MessageDecoder#get_list
    msg.get_unpack('n')[0] # => DNS::Message::MessageDecoder#get_unpack
  }

  return self.new(keys)
  # => DNS::SvcParam::Mandatory#initialize
end

# DNS::SvcParam::Mandatory#initialize

def initialize(keys)
  @keys = keys.map(&:to_int)
end
```

### `DNS::SvcParam::ALPN.decode`

```ruby
# class ALPN < SvcParam

def self.decode(msg) # :nodoc:
  # プロトコルIDの文字列配列を取得
  list = msg.get_string_list # => DNS::Message::MessageDecoder#get_string_list

  return self.new(list)
  # => DNS::SvcParam::ALPN#initialize
end

# DNS::SvcParam::ALPN#initialize

def initialize(protocol_ids)
  @protocol_ids = protocol_ids.map(&:to_str)
end
```

### `DNS::SvcParam::NoDefaultALPN.decode`

```ruby
# class NoDefaultALPN < SvcParam

def self.decode(msg) # :nodoc:
  return self.new
  # => DNS::SvcParam#initialize
end

# DNS::SvcParam#initialize

def initialize(value)
  @value = value
end
```

### `DNS::SvcParam::Port.decode`

```ruby
# class Port < SvcParam

def self.decode(msg) # :nodoc:
  # ポート番号を取得
  port, = msg.get_unpack('n') # => DNS::Message::MessageDecoder#get_unpack

  return self.new(port)
  # => DNS::SvcParam::Port#initialize
end

# DNS::SvcParam::Port#initialize

def initialize(port)
  @port = port.to_int
end
```

### `DNS::SvcParam::IPv4Hint.decode` WIP

```ruby
# class IPv4Hint < SvcParam

def self.decode(msg) # :nodoc:
  addresses = msg.get_list { # => DNS::Message::MessageDecoder#get_list
    bytes = msg.get_bytes(4) # => DNS::Message::MessageDecoder#get_bytes
    IPv4.new(bytes) # IPv4#initialize
  }
  return self.new(addresses)
end
```

### `DNS::SvcParam::IPv6Hint.decode` WIP

```ruby
# class IPv6Hint < SvcParam

def self.decode(msg) # :nodoc:
  addresses = msg.get_list { # => DNS::Message::MessageDecoder#get_list
    bytes = msg.get_bytes(16) # => DNS::Message::MessageDecoder#get_bytes
    IPv6.new(bytes) # => IPv6#initialize
  }
  return self.new(addresses)
end
```

### `DNS::SvcParam::DoHPath.decode` WIP

```ruby
# class DoHPatht < SvcParam

def self.decode(msg) # :nodoc:
  template = msg.get_bytes.force_encoding('utf-8') # => DNS::Message::MessageDecoder#get_bytes
  return self.new(template)
end
```

### `DNS::SvcParam::Generic.decode` WIP

```ruby
# class Generic < SvcParam

def self.decode(msg) # :nodoc:
  bytes = msg.get_bytes # => DNS::Message::MessageDecoder#get_bytes
  return self.new(bytes)
end
```

### `MDNS#each_address`

```ruby
# class MDNS < DNS

def each_address(name)
  name = Resolv::DNS::Name.create(name)

  return unless name[-1].to_s == 'local'

  super(name)
end
```
