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

  RESOLUTION_DELAY = 0.05
  CONNECTION_ATTEMPT_DELAY = 0.25

  def self.run
    self.new.run
  end

  def initialize
    @resolver = Resolv::DNS.new(nameserver_port: [NAMESERVER])
    @hostname_resolution_result = HostnameResolutionResult.new(RECORD_TYPES.size)
    @hostname_resolution_threads = []
    @address_candidate_list = AddressCandidateList.new(RECORD_TYPES)
    @connecting_sockets = {}
    @connected_socket = nil
    @port = ARGV[0] == :https ? HTTPS_PORT : HTTP_PORT

    @resolution_delay_expires_at = nil
    @connection_attempt_delay_expires_at = nil
  end

  def run
    now = current_clock_time

    @hostname_resolution_threads.concat(
      RECORD_TYPES.map { |type|
        thread = Thread.new(type) { |type| resolve_hostname(type) }
        Thread.pass
        thread
      }
    )

    count = 0 if DEBUG
    last_error = nil

    loop do
      count += 1 if DEBUG

      puts "[DEBUG] #{count}: ** Check for readying to connect **" if DEBUG
      puts "[DEBUG] #{count}: @address_candidate_list #{@address_candidate_list.instance_variable_get(:@addresses)&.transform_values(&:records)}" if DEBUG
      puts "[DEBUG] #{count}: resolution_delay_expires_at #{@resolution_delay_expires_at}" if DEBUG

      if @address_candidate_list.any?
          && !@resolution_delay_expires_at
          && !@connection_attempt_delay_expires_at
        address = @address_candidate_list.next_candidate
        addrinfo = Addrinfo.tcp(address, @port)

        if @address_candidate_list.empty? && @connecting_sockets.empty? && @address_candidate_list.all_resolved?
          begin
            socket = addrinfo.connect
            if ARGV[0] == :https
              ssl_socket = OpenSSL::SSL::SSLSocket.new(socket)
              ssl_socket.hostname = HOST
              ssl_socket.connect
              @connected_socket = ssl_socket
            else
              @connected_socket = socket
            end
          rescue SystemCallError => e
            socket&.close
            last_error = e
            raise last_error
          end
        else
          socket = Socket.new(addrinfo.afamily, Socket::SOCK_STREAM)
          result = socket.connect_nonblock(addrinfo, exception: false)

          if result == :wait_writable
            @connection_attempt_delay_expires_at = now + CONNECTION_ATTEMPT_DELAY
            @connecting_sockets[socket] = addrinfo
          end
        end
      end

      puts "[DEBUG] #{count}: resolution_delay_expires_at #{@resolution_delay_expires_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: connection_attempt_delay_expires_at #{@connection_attempt_delay_expires_at || 'nil'}" if DEBUG

      ends_at =
        if @address_candidate_list.any?
          @resolution_delay_expires_at || @connection_attempt_delay_expires_at
        else
          Float::INFINITY
        end

      puts "[DEBUG] #{count}: ends_at #{ends_at || 'nil'}" if DEBUG

      puts "[DEBUG] #{count}: ** Start to wait **" if DEBUG
      puts "[DEBUG] #{count}: IO.select(#{@hostname_resolution_result.notifier}, #{@connecting_sockets}, nil, 0)" if DEBUG
      puts "[DEBUG] #{count}: connection_attempt_delay_expires_at #{@connection_attempt_delay_expires_at || 'nil'}" if DEBUG

      resolved_notifier, writable_sockets, _ = IO.select(
        @hostname_resolution_result.notifier,
        @connecting_sockets.keys,
        nil,
        second_to_timeout(current_clock_time, ends_at),
      )

      now = current_clock_time
      @resolution_delay_expires_at = nil if expired?(now, @resolution_delay_expires_at)
      @connection_attempt_delay_expires_at = nil if expired?(now, @connection_attempt_delay_expires_at)

      puts "[DEBUG] #{count}: ** Check for writable_sockets **" if DEBUG
      puts "[DEBUG] #{count}: writable_sockets #{writable_sockets || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: connecting_sockets #{@connecting_sockets}" if DEBUG

      if writable_sockets&.any?
        while (writable_socket = writable_sockets.pop)
          is_connected = (
            sockopt = writable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)
            sockopt.int.zero?
          )

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
          else
            failed_ai = @connecting_sockets.delete writable_socket
            writable_socket.close
            ip_address = failed_ai.ipv6? ? "[#{failed_ai.ip_address}]" : failed_ai.ip_address
            last_error = SystemCallError.new("connect(2) for #{ip_address}:#{failed_ai.ip_port}", sockopt.int)

            if writable_sockets.any? || @connecting_sockets.any?
              # Try other writable socket
            elsif @address_candidate_list.any? || @address_candidate_list.any_unresolved?
              @connection_attempt_delay_expires_at = nil
            else
              raise last_error
            end
          end
        end
      end

      puts "[DEBUG] #{count}: ** Check for hostname resolution finish **" if DEBUG
      puts "[DEBUG] #{count}: resolved_notifier #{resolved_notifier || 'nil'}" if DEBUG
      if resolved_notifier&.any?
        while (result = @hostname_resolution_result.get)
          @address_candidate_list.add(result)
          last_error = result.error unless result.success?
        end

        # TODO HTTPS RRを考慮する
        if @address_candidate_list.resolved?(Resolv::DNS::Resource::IN::A)
          if @address_candidate_list.all_resolved?
            puts "[DEBUG] #{count}: All hostname resolution is finished" if DEBUG
            @hostname_resolution_result.close_notifier
            @resolution_delay_expires_at = nil
          elsif @address_candidate_list.resolved_successfully?(Resolv::DNS::Resource::IN::A)
            puts "[DEBUG] #{count}: Resolution Delay is ready" if DEBUG
            @resolution_delay_expires_at = now + RESOLUTION_DELAY
          end
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

    @connecting_sockets.each_key do |connecting_socket|
      connecting_socket.close
    end

    @hostname_resolution_threads.each do |thread|
      thread.exit
    end
  end

  private

  def resolve_hostname(type)
    records = @resolver.getresources(HOST, type).map { it.address.to_s }
    @hostname_resolution_result.add(type, records: records)
  rescue => e
    @hostname_resolution_result.add(type, error: e)
  end

  def current_clock_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def second_to_timeout(started_at, ends_at)
    return nil if ends_at == Float::INFINITY || ends_at.nil?

    remaining = (ends_at - started_at)
    remaining.negative? ? 0 : remaining
  end

  def expired?(started_at, ends_at)
    second_to_timeout(started_at, ends_at)&.zero?
  end

  class HostnameResolutionResult
    HOSTNAME_RESOLUTION_QUEUE_UPDATED = 1

    ResolutionResult = Data.define(:type, :records, :error) do
      def success?
        error.nil?
      end
    end

    attr_reader :notifier

    def initialize(size)
      @size = size
      @taken_count = 0
      @rpipe, @wpipe = IO.pipe
      @results = []
      @mutex = Mutex.new
      @notifier = [@rpipe]
    end

    def add(type, records: [], error: nil)
      @mutex.synchronize do
        @results.push ResolutionResult.new(type:, records:, error:)
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
      close_all if @taken_count == @size
      res
    end

    def close_notifier
      @rpipe.close if @notifier
    end

    private

    def close
      @rpipe.close
      @notifier = nil
      @wpipe.close
    end
  end

  class AddressCandidateList # WIP
    PRIORITY_ON_V6 = [Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A]
    PRIORITY_ON_V4 = [Resolv::DNS::Resource::IN::A, Resolv::DNS::Resource::IN::AAAA]

    def initialize(record_types)
      @record_types = record_types
      @addresses = {}
      @last_type = nil
    end

    def add(result)
      @addresses[result.type] = result
      return unless result.success?

      # TODO グルーピングが必要
      if result.type == Resolv::DNS::Resource::IN::HTTPS
        # WIP
      end
    end

    def next_candidate
      precedences =
        if @last_type == Resolv::DNS::Resource::IN::AAAA then PRIORITY_ON_V4
        elsif @last_type == Resolv::DNS::Resource::IN::A || @last_type.nil? then PRIORITY_ON_V6
        end

      precedences.each do |type|
        address = @addresses[type]&.records&.shift
        next unless address

        @last_type = type
        return address
      end

      nil
    end

    def resolved?(type)
      @addresses.key?(type)
    end

    def resolved_successfully?(type)
      @addresses[type]&.success?
    end

    def all_resolved?
      @record_types.all? { |type| resolved?(type) }
    end

    def any_unresolved?
      !all_resolved?
    end

    def empty?
      @addresses.all? { |_, result| result && result.records.empty? }
    end

    def any?
      !empty?
    end
  end
end

HTTPClient.run
