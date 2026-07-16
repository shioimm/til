require "socket"
require "resolv"
require "openssl"

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
    Resolv::DNS::Resource::IN::HTTPS,
  ].freeze

  RESOLUTION_DELAY = 0.05
  CONNECTION_ATTEMPT_DELAY = 0.25

  def self.run
    self.new.run
  end

  def initialize
    @use_ssl = ARGV[0] == :https
    @port = @use_ssl ? HTTPS_PORT : HTTP_PORT

    @resolver = Resolv::DNS.new(nameserver_port: [NAMESERVER])
    # TODO ホストの接続性によってHTTPS / AもしくはHTTPS / AAAAになる可能性あり
    @record_types = RECORD_TYPES
    @hostname_resolution_result = HostnameResolutionResult.new
    @address_candidate_list = AddressCandidateList.new(@record_types, self)
    @hostname_resolution_threads = []
    @connecting_sockets = {}
    @connected_socket = nil

    @resolution_delay_expires_at = nil
    @connection_attempt_delay_expires_at = nil
  end

  def run
    now = current_clock_time

    @record_types.each do |type|
      resolve_hostname_asynchronously!(type)
    end

    count = 0 if DEBUG
    last_error = nil

    loop do
      count += 1 if DEBUG

      puts "[DEBUG] #{count}: ** Check for readying to connect **" if DEBUG
      puts "[DEBUG] #{count}: @address_candidate_list #{@address_candidate_list.instance_variable_get(:@addresses)}" if DEBUG
      puts "[DEBUG] #{count}: resolution_delay_expires_at #{@resolution_delay_expires_at}" if DEBUG

      if @address_candidate_list.any?
          && !@resolution_delay_expires_at
          && !@connection_attempt_delay_expires_at
        ctx, address = @address_candidate_list.next_candidate
        addrinfo = Addrinfo.tcp(address, @port)

        if @address_candidate_list.empty? && @connecting_sockets.empty? && @address_candidate_list.all_resolved?
          begin
            connected_tcp_socket = addrinfo.connect
            @connected_socket = @use_ssl ? connect_with_tls(connected_tcp_socket, ctx) : connected_tcp_socket
          rescue SystemCallError => e
            connected_tcp_socket&.close
            last_error = e
            raise last_error
          end
        else
          socket = Socket.new(addrinfo.afamily, Socket::SOCK_STREAM)
          result = socket.connect_nonblock(addrinfo, exception: false)

          if result == :wait_writable
            @connection_attempt_delay_expires_at = now + CONNECTION_ATTEMPT_DELAY
            @connecting_sockets[socket] = [ctx, addrinfo]
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
            ctx, _ = @connecting_sockets.delete(writable_socket)
            # TBC connect_with_tlsも非同期でやる必要ある...?
            @connected_socket = @use_ssl ? connect_with_tls(writable_socket, ctx) : writable_socket
            break
          else
            _, failed_ai = @connecting_sockets.delete writable_socket
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
        @hostname_resolution_result.close_if_done

        if @address_candidate_list.resolved?(Resolv::DNS::Resource::IN::A)
          if @address_candidate_list.all_resolved? ||
              (@address_candidate_list.resolved?(Resolv::DNS::Resource::IN::HTTPS) &&
               @address_candidate_list.resolved?(Resolv::DNS::Resource::IN::AAAA))
            puts "[DEBUG] #{count}: All hostname resolution is finished" if DEBUG
            @hostname_resolution_result.close_notifier
            @resolution_delay_expires_at = nil
          else
            @address_candidate_list.resolved_successfully?(Resolv::DNS::Resource::IN::A)
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

  def resolve_hostname_asynchronously!(type, hostname = HOST)
    @hostname_resolution_result.count_up
    thread = Thread.new(type) { |type|
      @hostname_resolution_result.add(type, records: @resolver.getresources(hostname, type))
    rescue => e
      @hostname_resolution_result.add(type, error: e)
    }
    Thread.pass
    @hostname_resolution_threads.push(thread)
  end

  private

  def connect_with_tls(socket, ctx)
    ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, )
    ssl_socket.hostname = HOST
    ssl_socket.connect
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

    def initialize
      @size = 0
      @taken_count = 0
      @rpipe, @wpipe = IO.pipe
      @results = []
      @mutex = Mutex.new
      @notifier = [@rpipe]
    end

    def count_up
      @size += 1
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
      res
    end

    def close_if_done
      return if @notifier.nil?
      close_all if @taken_count == @size
    end

    def close_notifier
      return if @notifier.nil?

      @rpipe.close
      @notifier = nil
    end

    private

    def close_all
      @rpipe.close
      @notifier = nil
      @wpipe.close
    end
  end

  class AddressCandidateList
    PRIORITY_ON_V6 = [Resolv::DNS::Resource::IN::AAAA, Resolv::DNS::Resource::IN::A]
    PRIORITY_ON_V4 = [Resolv::DNS::Resource::IN::A, Resolv::DNS::Resource::IN::AAAA]
    SUPPORTED_PROTOCOLS = ["http/1.1"].freeze

    AddressCandidate = Data.define(:rr, :ipv6_address_hints, :ipv4_address_hints)

    def initialize(record_types, client)
      @record_types = record_types
      @addresses = {}
      @errors = {}
      @last_type = nil
      @client = client
    end

    def add(result)
      if result.type == Resolv::DNS::Resource::IN::HTTPS
        if result.records.first.alias_mode?
          @client.resolve_hostname_asynchronously!(result.type)
          return
        end

        supported_records = result.records.map { |rr| create_address_candidate_from_rr!(rr) }.compact
        return if supported_records.empty?

        candidates = supported_records.group_by { |candidate|
          target_name = candidate.rr.target.to_s

          if !target_name.empty? # TargetName != .
            @client.resolve_hostname_asynchronously!(Resolv::DNS::Resource::IN::AAAA, target_name)
            @client.resolve_hostname_asynchronously!(Resolv::DNS::Resource::IN::A, target_name)
          end

          [candidate.rr.priority, candidate.rr.params[1].protocol_ids]
        }

        # TODO グループを並び替えの上ノーマライズできるようにする
        candidate = candidates.values.flatten.first # TEMP
        @addresses[result.type] ||= {}
        @addresses[result.type][Resolv::DNS::Resource::IN::AAAA] = candidate.ipv6_address_hints
        @addresses[result.type][Resolv::DNS::Resource::IN::A] = candidate.ipv4_address_hints
      elsif result.success?
        https_hints = @addresses.dig(Resolv::DNS::Resource::IN::HTTPS, result.type)

        if https_hints&.any?
          ctx, _ = https_hints.first # TODO これでいいのか...?
          @addresses[Resolv::DNS::Resource::IN::HTTPS][result.type] = []
          # TODO 現状typeごとにアドレスを管理しているけど、優先度ごとに管理するようにした方がいいのかも
          # A/AAAAが遅れて解決できた場合はその値で置き換える
          @addresses[result.type] = result.records.map { [ctx, it.address.to_s] }
        else
          @addresses[result.type] = result.records.map { [nil, it.address.to_s] }
        end

        @errors[result.type] = nil
      else
        @addresses[result.type] = []
        @errors[result.type] = result.error
      end
    end

    def next_candidate
      precedences =
        if @last_type == Resolv::DNS::Resource::IN::AAAA then PRIORITY_ON_V4
        elsif @last_type == Resolv::DNS::Resource::IN::A || @last_type.nil? then PRIORITY_ON_V6
        end

      precedences.each do |type|
        candidate = @addresses[type]&.shift || @addresses[Resolv::DNS::Resource::IN::HTTPS]&.dig(type)&.shift

        next unless candidate

        @last_type = type
        return candidate
      end

      nil
    end

    def resolved?(type)
      @addresses.key?(type)
    end

    def resolved_successfully?(type)
      resolved?(type) && @errors[type].nil?
    end

    def all_resolved?
      @record_types.all? { |type| resolved?(type) }
    end

    def any_unresolved?
      !all_resolved?
    end

    def empty?
      @addresses.all? do |_, records|
        case records
        when Hash then records.all? { |_, addrs| addrs.empty? }
        when Array then records.empty?
        end
      end
    end

    def any?
      !empty?
    end

    private

    def create_address_candidate_from_rr!(rr)
      alpn = rr.params[1]&.protocol_ids

      if alpn.nil? || (alpn & SUPPORTED_PROTOCOLS).any?
        ctx = ::OpenSSL::SSL::SSLContext.new
        ctx.alpn_protocols = rr.params[1]&.protocol_ids
        ipv6_address_hints = rr.params[6]&.addresses&.map { [ctx, it] } || []
        ipv4_address_hints = rr.params[4]&.addresses&.map { [ctx, it] } || []
        AddressCandidate.new(rr, ipv6_address_hints, ipv4_address_hints)
      end
    end
  end
end

HTTPClient.run
