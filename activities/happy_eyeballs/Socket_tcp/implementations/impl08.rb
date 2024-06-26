require 'socket'

# ここまでの実装:
#   変更:
#     アドレスを格納するチャネルを汎用的なキューからAddrinfoの格納に適したものへ変更した
#     ResolvをAddrinfo.getaddrinfoへ置き換え、HostnameResolutionでは文字列ではなくAddrinfoを取得するようにした
#   機能追加:
#     AddressResourceStorage#pick (アドレスの取得を行う、最後に接続したアドレスがある場合は選択も行う)
#   機能削除
#     AddressResourceStorage#take (アドレスの取得のみを行う)
#
# 次にやること:
#   接続試行をメインスレッドでノンブロッキングモードで行い、接続中のソケットをcloseできるようにする

class AddressResourceStorage
  def initialize
    @resources = []
    @mutex = Mutex.new
    @cond = ConditionVariable.new
  end

  def add(resource)
    @mutex.synchronize do
      @resources.push(*resource)
      @cond.signal
    end
  end

  def pick(last_family = nil, timeout: nil)
    @mutex.synchronize do
      @cond.wait(@mutex, timeout) if @resources.empty?

      if last_family && (addrinfo = @resources.find { |addrinfo| !addrinfo.afamily == last_family })
        @resources.delete addrinfo
      else
        @resources.shift
      end
    end
  end

  def resources
    @mutex.synchronize do
      @resources
    end
  end

  def include_ipv6?
    @resources.any?(&:ipv6?)
  end
end

class HostnameResolution
  RESOLUTION_DELAY = 0.05

  def initialize(address_resource_storage)
    @address_resource_storage = address_resource_storage
  end

  def get_address_resources!(hostname, port, family)
    resources = Addrinfo.getaddrinfo(hostname, port, family, :STREAM)

    if family == :PF_INET4 && !@address_resource_storage.include_ipv6?
      sleep RESOLUTION_DELAY
    end

    @address_resource_storage.add resources
  end
end

class ConnectionAttemptDelayTimer
  CONNECTION_ATTEMPT_DELAY = 0.25

  @mutex = Mutex.new
  @timers = []

  class << self
    def start_new_timer
      @mutex.synchronize do
        @timers << self.new
      end
    end

    def take_timer
      @mutex.synchronize do
        @timers.shift
      end
    end
  end

  def initialize
    @starts_at = Time.now
    @ends_at = @starts_at + CONNECTION_ATTEMPT_DELAY
  end

  def timein?
    @ends_at > Time.now
  end

  def waiting_time
    @ends_at - Time.now
  end
end

class ConnectionAttempt
  def initialize(connected_sockets, address_resource_storage)
    @connected_sockets = connected_sockets
    @address_resource_storage = address_resource_storage
  end

  def attempt!(addrinfo)
    if (timer = ConnectionAttemptDelayTimer.take_timer) && timer.timein?
      sleep timer.waiting_time
    end

    return if !@connected_sockets.empty?

    ConnectionAttemptDelayTimer.start_new_timer
    connected_socket = addrinfo.connect
    @address_resource_storage.add nil # WAITING_DNS_REPLY_SECONDを待たずに接続試行を終了させる
    Mutex.new.synchronize { @connected_sockets.push connected_socket }
  end
end

HOSTNAME = "localhost"
PORT = 9292

# アドレス解決 (Producer)
address_resource_storage = AddressResourceStorage.new
hostname_resolution = HostnameResolution.new(address_resource_storage)

[:PF_INET6, :PF_INET].each do |family|
  Thread.new { hostname_resolution.get_address_resources!(HOSTNAME, PORT, family) }
end

# 接続試行 (Consumer)
CONNECTING_THREADS = ThreadGroup.new
connected_sockets = []
connection_attempt = ConnectionAttempt.new(connected_sockets, address_resource_storage)
last_attemped_family = nil

# RFC8305: Connection Attempts
# the DNS client resolver SHOULD still process DNS replies from the network
# for a short period of time (recommended to be 1 second)
WAITING_DNS_REPLY_SECOND = 1

connected_socket = loop do
  addrinfo = address_resource_storage.pick(last_attemped_family, timeout: WAITING_DNS_REPLY_SECOND)

  if addrinfo.nil?
    connected_socket = connected_sockets.shift
    CONNECTING_THREADS.list.each(&:exit)
    connected_sockets.each(&:close)
    break connected_socket
  end

  last_attemped_family = addrinfo.afamily

  t = Thread.start(addrinfo) { |addrinfo| connection_attempt.attempt!(addrinfo) }

  CONNECTING_THREADS.add(t)
end

CONNECTING_THREADS.list.each(&:join)

connected_socket.write "GET / HTTP/1.0\r\n\r\n"
print connected_socket.read
connected_socket.close
