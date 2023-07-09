require 'resolv'
require 'socket'

class ClientAddrinfo
  attr_reader :addrinfo

  def initialize(addrinfo)
    @addrinfo = addrinfo
  end
end

class ConnectionAttempt
  class DelayingAttempt
    def initialize(attempt)
      @attempt = attempt
    end

    def try_to_attempt
      loop do
        if !ConnectionAttemptDelayTimer.delaying?
          @attempt.resume
          ConnectionAttemptDelayTimer.update
          break
        end

        sleep 0.001
      end
    end
  end

  def initialize
    @mutex = Mutex.new
    @connectable = ConditionVariable.new
  end

  def attempt(client)
    @mutex.synchronize do
      DelayingAttempt.new(self).try_to_attempt if delaying?
      @connectable.wait(@mutex) if delaying?
    end

    ConnectionAttemptDelayTimer.start_timer

    sock = client.addrinfo.connect
    sock.write "GET / HTTP/1.0\r\n\r\n"
    print sock.read
    sock.close

    (WORKING_THREADS.list - [Thread.current]).each(&:kill)
  end

  def resume
    @connectable.signal
  end

  private

  def delaying?
    ConnectionAttemptDelayTimer.delaying?
  end
end

class ConnectionAttemptDelayTimer
  CONNECTION_ATTEMPT_DELAY = 0.25

  @mutex = Mutex.new
  @timers = []

  class << self
    def delaying?
      !@timers.empty? && !timeout?
    end

    def start_timer
      @mutex.synchronize do
        @timers << self.new
      end
    end

    def update
      @mutex.synchronize do
        @timers.delete_at 0
      end
    end

    private

    def timeout?
      Time.now > @timers.first.connecting_starts_at + CONNECTION_ATTEMPT_DELAY
    end
  end

  attr_reader :connecting_starts_at

  def initialize
    @connecting_starts_at = Time.now
  end
end

# アドレス解決
hostname = "localhost"
resolver = Resolv::DNS.new
type_classes = [Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A]

addresses = []
# 値が入るのを監視する必要あり。配列ではなく専用のクラスを用意してwaiting_clientsと合流させた方がいいかも

# TODO: 一旦スレッドでアドレス解決を行うようにしただけ
type_classes.each do |type|
  addresses << Thread.new { resolver.getresource(hostname, type) }.value.address.to_s
  # 返ってきたのがIPv6アドレスの場合、返ってきたことを示すフラグを立ててaddressesにClientAddrinfoを追加
  # 返ってきたのがIPv4アドレスの場合、フラグを確認する
  #   フラグが立っていればaddressesにClientAddrinfoを追加
  #   フラグが立っていなければResolution Delay -> addressesにClientAddrinfoを追加
  #   ClientAddrinfoを作るため、返ってきた文字列がIPv6なのかIPv4なのかを判断するための手段を用意する
  #
  # addressesは自身に値が追加されるのを待つ -> 値を追加したスレッドがConnectionAttemptを実施
  #   addressesに値を追加したスレッドがaddressesにシグナルを送る
  # addressesは値の追加の待機のキャンセルを待つ
  #   ConnectionAttemptに成功したスレッドがaddressesにシグナルを送る
  #   DNSクエリを行うtype_classesが尽きたらメインスレッドがaddressesにシグナルを送る
  #
  # 終了要件 (正常系) :
  #   接続を確立したスレッドから接続ソケットを得ること
  #   addressesの待機状態が解除されていること
  #   接続を確立したスレッド以外のスレッドが終了していること
  #
  # 単一のスレッドがDNSクエリから接続試行まで行えば
  # タイマーと動作中のスレッドを管理する機構だけが必要でaddressesに貯める処理は不要では?
  #   -> DNS回答が複数のレコードを含んでいる場合には単一のアドレスファミリに複数のスレッドが必要
  #
  # Producer-Consumerパターンを利用する
  #   Producer側はClientAddrinfoをaddressesに置く
  #   Consumer側 (メインスレッド) はClientAddrinfoをaddressesから取り出し、スレッドを生成して接続試行
  #     ConsumerがaddressesからClientAddrinfoを取り出すのを止める契機を用意する (タイムアウト?)
end

# 接続試行
waiting_clients = []
port = 9292
ipv6_addr, ipv4_addr = addresses

ipv4_sockaddr = Socket.sockaddr_in(port, ipv4_addr)
ipv4_addrinfo = Addrinfo.new(ipv4_sockaddr, Socket::AF_INET, Socket::SOCK_STREAM, 0)
waiting_clients.push(ClientAddrinfo.new(ipv4_addrinfo))

ipv6_sockaddr = Socket.sockaddr_in(port, ipv6_addr)
ipv6_addrinfo = Addrinfo.new(ipv6_sockaddr, Socket::AF_INET6, Socket::SOCK_STREAM, 0)
waiting_clients.push(ClientAddrinfo.new(ipv6_addrinfo))

WORKING_THREADS = ThreadGroup.new
connection_attempt = ConnectionAttempt.new

while client = waiting_clients.shift
  t = Thread.start(client) do |client|
    connection_attempt.attempt(client)
  end

  WORKING_THREADS.add t
end

WORKING_THREADS.list.each(&:join)
