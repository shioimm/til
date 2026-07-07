require "socket"
require "resolv"

DEBUG = true

# TODO IPv6 / IPv4接続性確認
# TODO 6to4アドレス合成

class HTTPClient
  NAMESERVER = ["127.0.0.1", 5300]
  HOST = "localhost"
  HTTPS_PORT = 8443
  HTTP_PORT = 8080
  RECORD_TYPES = [
    Resolv::DNS::Resource::IN::A,
    Resolv::DNS::Resource::IN::AAAA,
  ].freeze # TODO HTTPSレコードを追加

  def self.run
    self.new.run
  end

  def initialize
    @resolver = Resolv::DNS.new(nameserver_port: [NAMESERVER])
    @hostname_resolution_result = HostnameResolutionResult.new(RECORD_TYPES.size)
    @hostname_resolution_threads = []
    @address_candidate_list = AddressCandidateList.new
    @connecting_sockets = []
    @connected_socket = nil
    @port = ARGV[0] == :https ? HTTPS_PORT : HTTP_PORT
  end

  def run
    @hostname_resolution_threads.concat(
      RECORD_TYPES.map { |type|
        thread = Thread.new(type) { |type| resolve_hostname(type) }
        Thread.pass
        thread
      }
    )

    count = 0 if DEBUG

    loop do
      count += 1 if DEBUG

      puts "[DEBUG] #{count}: ** Check for readying to connect **" if DEBUG
      puts "[DEBUG] #{count}: @address_candidate_list #{@address_candidate_list.instance_variable_get(:@addresses)}" if DEBUG
      if @address_candidate_list.any?
        address = @address_candidate_list.next_candidate
        addrinfo = Addrinfo.tcp(address, @port)
        socket = Socket.new(addrinfo.afamily, Socket::SOCK_STREAM)

        socket.connect_nonblock(addrinfo, exception: false)
        @connecting_sockets.push socket
      end

      puts "[DEBUG] #{count}: ** Start to wait **" if DEBUG
      puts "[DEBUG] #{count}: IO.select(#{@hostname_resolution_result.notifier}, #{@connecting_sockets}, nil, 0)" if DEBUG
      # TODO RD / CADタイムアウト設定
      resolved_notifier, writable_sockets, _ = IO.select(
        @hostname_resolution_result.notifier,
        @connecting_sockets,
        nil,
        0,
      )

      puts "[DEBUG] #{count}: ** Check for writable_sockets **" if DEBUG
      puts "[DEBUG] #{count}: writable_sockets #{writable_sockets || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: connecting_sockets #{@connecting_sockets}" if DEBUG

      if writable_sockets&.any?
        while (writable_socket = writable_sockets.pop)
          is_connected = (
            sockopt = writable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)
            sockopt.int.zero?
          )

          # TODO エラーハンドリング
          if is_connected
            @connecting_sockets.delete writable_socket

            if ARGV[0] == :https
              ssl_socket = OpenSSL::SSL::SSLSocket.new(writable_socket)
              ssl_socket.hostname = HOST
              ssl_socket.connect # TODO 接続確認
              ssl_socket
              @connected_socket = ssl_socket
            else
              @connected_socket = writable_socket
            end

            break
          end
        end
      end

      puts "[DEBUG] #{count}: ** Check for hostname resolution finish **" if DEBUG
      puts "[DEBUG] #{count}: resolved_notifier #{resolved_notifier || 'nil'}" if DEBUG
      if resolved_notifier&.any?
        while (result = @hostname_resolution_result.get)
          # TODO エラーハンドリング・グルーピング・並べ替え
          @address_candidate_list.add(result)
        end
      end

      puts "------------------------" if DEBUG

      break if @connected_socket
    end

    request_message = "GET / HTTP/1.1\r\nHost: #{HOST}\r\nConnection: close\r\n\r\n"
    @connected_socket.write request_message

    response_message = @connected_socket.read
    status_line, *rest = response_message.split("\r\n")
    _, body = rest.join("\r\n").split("\r\n\r\n", 2)

    puts status_line
    puts body
  ensure
    @hostname_resolution_result.close_notifier

    @connecting_sockets.each do |connecting_socket|
      connecting_socket.close
    end

    @hostname_resolution_threads.each do |thread|
      thread.exit
    end
  end

  private

  def resolve_hostname(type)
    begin
      records = @resolver.getresources(HOST, type).map { it.address.to_s }
      @hostname_resolution_result.add(type, records)
    rescue => e
      @hostname_resolution_result.add(type, e)
    end
  end

  class HostnameResolutionResult
    HOSTNAME_RESOLUTION_QUEUE_UPDATED = 1

    attr_reader :notifier

    def initialize(size)
      @size = size
      @taken_count = 0
      @rpipe, @wpipe = IO.pipe
      @results = []
      @mutex = Mutex.new
      @notifier = [@rpipe]
    end

    def add(type, result)
      @mutex.synchronize do
        @results.push [type, result]
        @wpipe.putc HOSTNAME_RESOLUTION_QUEUE_UPDATED
      end
    end

    def get
      return nil if @results.empty?

      res = nil

      @mutex.synchronize do
        @rpipe.getbyte
        res = @results.shift
      end

      @taken_count += 1
      close if @taken_count == @size
      res
    end

    def close
      @rpipe.close
      @notifier = nil
      @wpipe.close
    end

    def close_notifier
      @rpipe.close if @notifier
    end
  end

  class AddressCandidateList # WIP
    PRIORITY_ON_V6 = [Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A]
    PRIORITY_ON_V4 = [Resolv::DNS::Resource::IN::A, Resolv::DNS::Resource::IN::AAAA]

    def initialize
      @groups = []
      # TODO @groupsの中に@addressesが必要
      @addresses = {
        Resolv::DNS::Resource::IN::AAAA => [],
        Resolv::DNS::Resource::IN::A => [],
      }
      @last_type = nil
    end

    def add(result)
      type, records = result

      # TODO グルーピングが必要
      if type == Resolv::DNS::Resource::IN::HTTPS
        # WIP
      else
        # TODO アドレスヒントを置き換える処理が必要
        @addresses[type].concat(records)
      end
    end

    def next_candidate
      precedences =
        if @last_type == Resolv::DNS::Resource::IN::AAAA then PRIORITY_ON_V4
        elsif @last_type == Resolv::DNS::Resource::IN::A || @last_type.nil? then PRIORITY_ON_V6
        end

      precedences.each do |type|
        address = @addresses[type]&.shift
        next unless address

        @last_type = type
        return address
      end

      nil
    end

    def empty?
      @addresses.all? { |_, addrinfos| addrinfos.empty? }
    end

    def any?
      !empty?
    end
  end
end

HTTPClient.run
