# TL;DR
#   アドレスファミリごとにスレッドを生成してそれぞれアドレス解決を試行
#     それぞれのスレッド内でアドレス解決を終えたら (Resolution Delayを終えたら) Repositoryに書き込む
#   メインスレッドでRepositoryからアドレスを取得できたら取得した順にスレッドを生成し接続試行
#     接続試行ごとにConnection Attempt Delay Timerを生成
#     Connection Attempt Delay Timerがある場合は終了まで待機
#     ブロッキングモードで接続試行
#
# PR#4038との違い
#   アドレスの取得をRepositoryへの追加で表現している
#   Resolution Delayに実行条件がある
#   Resolution Delayの間、Repositoryへのアドレス追加を待機することによってこれを表現している
#   (これによってRepository内のアドレスは良くも悪くもフラットに扱われる)
#   接続試行を行うアドレスごとにスレッドを生成し、ブロッキングモードで接続試行を行なっている
#   Connection Attempt Delayをタイマーの配列によって表現している
#   WAITING_DNS_REPLY_SECONDを待っている
#
# 追加で必要な機能
#   Socket.tcpのインターフェースに関連するもの
#     local_host
#     local_port
#     connect_timeout
#     resolv_timeout
#   Happy Eyeballsに関連するもの
#     アドレス選択機能
#       接続試行開始済みの場合、前回接続アドレスファミリとは異なるアドレスファミリを選択する
#       接続試行開始前の場合、IPv6アドレスを優先する
#       Repositoryを拡張し、アドレスファミリで選択できるようにする
#       このために、ソケットの取得はRepositoryを利用せずに行うようにする (Queue?)
#
# 修正する機能
#   接続試行をメインスレッドで行う
#     ノンブロッキングモードで順に接続試行し、IO.selectでいずれかの接続を待つ
#       接続中のソケットがある限りループさせ、その中でConnection Attempt Delayを表現する
#       そうしないと接続試行中のソケットをcloseできない
#     作成したソケットのうち、接続に成功していないものを終了時にcloseする

require 'resolv'
require 'socket'

class Repository
  def initialize
    @collection = []
    @mutex = Mutex.new
    @cond = ConditionVariable.new
  end

  def add(resource)
    @mutex.synchronize do
      if resource.is_a? Array
        @collection.push(*resource)
      else
        @collection.push(resource)
      end
      @cond.signal
    end
  end

  def take(timeout = nil)
    @mutex.synchronize do
      @cond.wait(@mutex, timeout) if @collection.empty?
      @collection.shift
    end
  end

  def collection
    @mutex.synchronize do
      @collection
    end
  end

  def include_ipv6?
    @collection.any? { |address| address.is_a? Resolv::DNS::Resource::IN::AAAA }
  end
end

class HostnameResolution
  RESOLUTION_DELAY = 0.05

  def initialize(address_repository)
    @resolver = Resolv::DNS.new
    @address_repository = address_repository
  end

  def get_address_resources!(hostname, type)
    addresses = @resolver.getresources(hostname, type).map { |resource| resource.address.to_s }

    if type == Resolv::DNS::Resource::IN::A && !@address_repository.include_ipv6?
      sleep RESOLUTION_DELAY
    end

    @address_repository.add addresses
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
  def initialize(socket_repository, address_repository)
    @socket_repository = socket_repository
    @address_repository = address_repository
  end

  def attempt!(addrinfo)
    if (timer = ConnectionAttemptDelayTimer.take_timer) && timer.timein?
      sleep timer.waiting_time
    end

    return nil if !@socket_repository.collection.empty?

    ConnectionAttemptDelayTimer.start_new_timer
    connected_socket = addrinfo.connect
    @address_repository.add nil # WAITING_DNS_REPLY_SECONDを待たずに接続試行を終了させる
    @socket_repository.add connected_socket
  end
end

HOSTNAME = "localhost"
PORT = 9292

# アドレス解決 (Producer)
address_repository = Repository.new
hostname_resolution = HostnameResolution.new(address_repository)

[Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A].each do |type|
  Thread.new { hostname_resolution.get_address_resources!(HOSTNAME, type) }
end

# 接続試行 (Consumer)
CONNECTING_THREADS = ThreadGroup.new
socket_repository = Repository.new
connection_attempt = ConnectionAttempt.new(socket_repository, address_repository)

# RFC8305: Connection Attempts
# the DNS client resolver SHOULD still process DNS replies from the network
# for a short period of time (recommended to be 1 second)
WAITING_DNS_REPLY_SECOND = 1

connected_socket = loop do
  address = address_repository.take(WAITING_DNS_REPLY_SECOND)

  if address.nil?
    connected_socket = socket_repository.take
    CONNECTING_THREADS.list.each(&:exit)
    socket_repository.collection.each(&:close)
    break connected_socket
  end

  t = Thread.start(address, socket_repository) do |address, socket_repository|
    family = case address
             when /\w*:+\w*/       then Socket::AF_INET6 # IPv6
             when /\d+.\d+.\d+.\d/ then Socket::AF_INET  # IPv4
             else
               raise StandardError
             end

    sockaddr = Socket.sockaddr_in(PORT, address)
    addrinfo = Addrinfo.new(sockaddr, family, Socket::SOCK_STREAM, 0)
    connection_attempt.attempt!(addrinfo)
  end

  CONNECTING_THREADS.add(t)
end

CONNECTING_THREADS.list.each(&:join)

connected_socket.write "GET / HTTP/1.0\r\n\r\n"
print connected_socket.read
connected_socket.close
