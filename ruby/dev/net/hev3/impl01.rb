require "socket"
require "resolv"
require "openssl"
require "ipaddr"

DEBUG = true

class HTTPClient
  AAAA_TYPE  = Resolv::DNS::Resource::IN::AAAA
  A_TYPE     = Resolv::DNS::Resource::IN::A
  HTTPS_TYPE = Resolv::DNS::Resource::IN::HTTPS

  NAMESERVER = ["127.0.0.1", 5300]
  HOST = "localhost"
  HTTPS_PORT = 8443
  HTTP_PORT = 8080
  RESOLUTION_DELAY = 0.05
  CONNECTION_ATTEMPT_DELAY = 0.25

  WELL_KNOWN_IPV4_ADDRESSES = [
    IPAddr.new("192.0.0.170").to_i,
    IPAddr.new("192.0.0.171").to_i,
  ].freeze
  NAT64_PREFIX_LENGTHS = [32, 40, 48, 56, 64, 96].freeze

  def self.run
    self.new.run
  end

  def initialize
    @use_ssl = ARGV[0] == :https
    @port = @use_ssl ? HTTPS_PORT : HTTP_PORT

    @resolver = Resolv::DNS.new(nameserver_port: [NAMESERVER])
    @record_types = record_types
    @hostname_resolution_result = HostnameResolutionResult.new
    @address_candidate_list = AddressCandidateList.new(@record_types, self, nat64_prefix:)
    @hostname_resolution_threads = []
    @connecting_sockets = {}
    @tls_handshaking_sockets = {}
    @connected_socket = nil
    @tls_connected_socket = nil

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
        ctx, address, hostname = @address_candidate_list.next_candidate
        addrinfo = Addrinfo.tcp(address.to_s, @port)

        if !@use_ssl &&
            @address_candidate_list.empty? &&
            @connecting_sockets.empty? &&
            @address_candidate_list.all_resolved?
          begin
            @connected_socket = addrinfo.connect
          rescue SystemCallError => e
            last_error = e
            raise last_error
          end
        else
          socket = Socket.new(addrinfo.afamily, Socket::SOCK_STREAM)
          begin
            socket.connect_nonblock(addrinfo)
            @connected_socket = socket
            break
          rescue IO::WaitWritable
            @connection_attempt_delay_expires_at = now + CONNECTION_ATTEMPT_DELAY
            @connecting_sockets[socket] = [ctx, addrinfo, hostname]
          rescue SystemCallError => e
            socket.close
            last_error = e
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

      readable_ios, writable_sockets, _ = IO.select(
        (@hostname_resolution_result.notifier || []) + @tls_handshaking_sockets.keys,
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
            ctx, _, hostname = @connecting_sockets.delete(writable_socket)
            if @use_ssl
              nonblocking_connect_with_tls(writable_socket, ctx, hostname)
            else
              @connected_socket = writable_socket
              break
            end
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

      ssl_ready_sockets, dns_ready = (readable_ios || []).partition { @tls_handshaking_sockets.key?(it) }

      if ssl_ready_sockets.any?
        ssl_ready_sockets.each do |ssl_socket|
          begin
            ssl_socket.connect_nonblock
            @tls_handshaking_sockets.delete(ssl_socket)
            @tls_connected_socket = ssl_socket
            break
          rescue IO::WaitReadable
          rescue OpenSSL::SSL::SSLError, SystemCallError => e
            @tls_handshaking_sockets.delete(ssl_socket)
            ssl_socket.close
            last_error = e
          end
        end
      end

      puts "[DEBUG] #{count}: ** Check for hostname resolution finish **" if DEBUG
      puts "[DEBUG] #{count}: dns_ready #{dns_ready}" if DEBUG
      if dns_ready.any?
        while (result = @hostname_resolution_result.get)
          @address_candidate_list.add(result)
          last_error = result.error unless result.success?
        end
        @hostname_resolution_result.close_if_done

        if @address_candidate_list.any?
          if @address_candidate_list.all_resolved? ||
              (@address_candidate_list.resolved?(HTTPS_TYPE) &&
               @address_candidate_list.resolved?(AAAA_TYPE))
            puts "[DEBUG] #{count}: All hostname resolution is finished" if DEBUG
            @hostname_resolution_result.close_notifier
            @resolution_delay_expires_at = nil
          elsif @resolution_delay_expires_at.nil?
            puts "[DEBUG] #{count}: Resolution Delay is ready" if DEBUG
            @resolution_delay_expires_at = now + RESOLUTION_DELAY
          end
        end
      end

      puts "------------------------" if DEBUG

      break if @connected_socket || @tls_connected_socket
    end

    socket = @tls_connected_socket || @connected_socket
    request_message = "GET / HTTP/1.1\r\nHost: #{HOST}\r\nConnection: close\r\n\r\n"
    socket.write request_message

    response_message = socket.read
    status_line, *rest = response_message.split("\r\n")
    _, body = rest.join("\r\n").split("\r\n\r\n", 2)

    puts status_line
    puts body
  ensure
    @hostname_resolution_result.close_notifier

    @connecting_sockets.each_key do |connecting_socket|
      connecting_socket.close
    end

    @tls_handshaking_sockets.each_key do |ssl_socket|
      ssl_socket.close rescue nil
    end

    @hostname_resolution_threads.each do |thread|
      thread.exit
    end
  end

  def resolve_hostname_asynchronously!(type, hostname = HOST)
    @hostname_resolution_result.count_up

    thread = Thread.new(type) do |type|
      @hostname_resolution_result.add(type, hostname, records: @resolver.getresources(hostname, type))
    rescue => e
      @hostname_resolution_result.add(type, hostname, error: e)
    end

    Thread.pass
    @hostname_resolution_threads.push(thread)
  end

  private

  def record_types
    if ipv6_reachable? && ipv4_reachable?
      [HTTPS_TYPE, AAAA_TYPE, A_TYPE]
    elsif ipv6_reachable?
      nat64_prefix ? [HTTPS_TYPE, AAAA_TYPE, A_TYPE] : [HTTPS_TYPE, AAAA_TYPE]
    elsif ipv4_reachable?
      [HTTPS_TYPE, A_TYPE]
    else
      raise "no network connectivity"
    end
  end

  def ipv4_reachable?
    return @ipv4_reachable if defined?(@ipv4_reachable)

    @ipv4_reachable = begin
      socket = UDPSocket.new(Socket::AF_INET)
      socket.connect("8.8.8.8", 443)

      n = IPAddr.new(socket.local_address.ip_address).to_i
      # 0.0.0.0, 127.0.0.0/8, 169.254.0.0/16
      n != 0 && (n & 0xff000000) != 0x7f000000 && (n & 0xffff0000) != 0xa9fe0000
    rescue SystemCallError, SocketError
      false
    ensure
      socket&.close
    end
  end

  def ipv6_reachable?
    return @ipv6_reachable if defined?(@ipv6_reachable)

    @ipv6_reachable = begin
      socket = UDPSocket.new(Socket::AF_INET6)
      socket.connect("2001:4860:4860::8888", 443)

      n = IPAddr.new(socket.local_address.ip_address).to_i
      # ::, ::1, fe80::/10
      n != 0 && n != 1 && (n >> 118) != 0x3fa
    rescue SystemCallError, SocketError
      false
    ensure
      socket&.close
    end
  end

  def nat64_prefix
    return @nat64_prefix if defined?(@nat64_prefix)
    @nat64_prefix = detect_nat64_prefix
  end

  def detect_nat64_prefix
    addresses = @resolver.getresources("ipv4only.arpa", AAAA_TYPE).map { |rr|
      AddrInt.new(IPAddr.new_ntoh(rr.address.address).to_i)
    }
    prefixed_v4s = {}

    addresses.each do |addr_int|
      NAT64_PREFIX_LENGTHS.each do |prefix_len|
        next if prefix_len < 96 && !addr_int.u_octet_zero?

        v4 = addr_int.embedded_ipv4(prefix_len)
        next unless WELL_KNOWN_IPV4_ADDRESSES.include?(v4)

        label = addr_int.label(prefix_len)
        existing_v4s = prefixed_v4s[label] || []
        prefixed_v4s[label] = existing_v4s | [v4]

        return label if WELL_KNOWN_IPV4_ADDRESSES.all? { |known| prefixed_v4s[label].include?(known) }
      end
    end

    nil
  rescue Resolv::ResolvError, Resolv::ResolvTimeout
    nil
  end

  def nonblocking_connect_with_tls(tcp_socket, ctx, hostname)
    ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ctx)
    ssl_socket.hostname = hostname
    begin
      ssl_socket.connect_nonblock
      @tls_connected_socket = ssl_socket
    rescue IO::WaitReadable
      @tls_handshaking_sockets[ssl_socket] = hostname
    end
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

    ResolutionResult = Data.define(:type, :hostname, :records, :error) do
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

    def add(type, hostname, records: [], error: nil)
      @mutex.synchronize do
        @results.push ResolutionResult.new(type:, hostname:, records:, error:)
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
    PRIORITY_ON_V6 = [AAAA_TYPE, A_TYPE]
    PRIORITY_ON_V4 = [A_TYPE, AAAA_TYPE]
    SUPPORTED_PROTOCOLS = ["http/1.1"].freeze
    DEFAULT_ALPN = ["http/1.1"].freeze

    AddressCandidate = Data.define(:rr, :ctx, :ipv6_address_hints, :ipv4_address_hints)

    def initialize(record_types, client, nat64_prefix: nil)
      @record_types = record_types
      @addresses = {}
      @errors = {}
      @last_type = nil
      @client = client
      @nat64_prefix = nat64_prefix
    end

    def add(result)
      if result.type == HTTPS_TYPE
        if result.records.empty?
          @errors[HTTPS_TYPE] = nil
          return
        end

        if result.records.first.alias_mode?
          @client.resolve_hostname_asynchronously!(HTTPS_TYPE, result.records.first.target.to_s)
          return
        end

        supported_records = result.records.map { |rr| create_address_candidate_from_rr!(rr) }.compact
        @errors[HTTPS_TYPE] = nil
        return if supported_records.empty?

        sorted_candidates = supported_records.sort_by { |c| c.rr.priority }

        sorted_candidates.each do |candidate|
          target_name = candidate.rr.target.to_s
          hostname = target_name.empty? ? result.hostname : target_name
          priority = candidate.rr.priority
          temp_rr = @addresses.delete([hostname, Float::INFINITY])

          synthesized_ipv4_hints = @nat64_prefix ?
            candidate.ipv4_address_hints.map { |hint| synthesize_with_nat64_prefix(hint) } :
            candidate.ipv4_address_hints

          @addresses[[hostname, priority]] = {
            AAAA_TYPE  => temp_rr&.dig(AAAA_TYPE) || [],
            A_TYPE     => temp_rr&.dig(A_TYPE) || [],
            HTTPS_TYPE => { AAAA_TYPE => candidate.ipv6_address_hints, A_TYPE => synthesized_ipv4_hints },
            :ctx       => candidate.ctx,
          }

          if !target_name.empty?
            @client.resolve_hostname_asynchronously!(AAAA_TYPE, target_name)
            @client.resolve_hostname_asynchronously!(A_TYPE, target_name)
          end
        end
      elsif result.success?
        key =
          @addresses.keys.find { |(hostname, _priority)| hostname == result.hostname } ||
          [result.hostname, Float::INFINITY]

        @addresses[key] ||= { AAAA_TYPE => [], A_TYPE => [] }

        @addresses[key][result.type] = result.type == A_TYPE && @nat64_prefix ?
          result.records.map { |rr| synthesize_with_nat64_prefix(rr.address) } :
          result.records.map(&:address)

        @addresses[key][HTTPS_TYPE]&.delete(result.type)
        @errors[result.type] = nil
      else
        @errors[result.type] = result.error
      end
    end

    def next_candidate
      @addresses
        .group_by { |(_hostname, priority), _| priority }
        .sort_by { |priority, _entries| priority }
        .each do |_priority, entries|
          precedences.each do |type|
            candidates = entries.select { |_priority, data| address_available?(data, type) }
            next if candidates.empty?

            (hostname, _priority), data = candidates.to_a.sample
            address = data[type]&.shift || data[HTTPS_TYPE]&.dig(type)&.shift
            @last_type = type
            return [data[:ctx], address, hostname]
          end
        end

      nil
    end

    def resolved?(type)
      @errors.key?(type)
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
      @addresses.none? { |_, data| [AAAA_TYPE, A_TYPE].any? { |type| address_available?(data, type) } }
    end

    def any?
      !empty?
    end

    private

    def create_address_candidate_from_rr!(rr)
      alpn_protocols = extract_alpn_protocols_from_rr(rr)
      return if alpn_protocols.empty?

      ctx = ::OpenSSL::SSL::SSLContext.new
      ctx.alpn_protocols = alpn_protocols
      ipv6_address_hints = rr.params[6]&.addresses || []
      ipv4_address_hints = rr.params[4]&.addresses || []
      AddressCandidate.new(rr:, ctx:, ipv6_address_hints:, ipv4_address_hints:)
    end

    def extract_alpn_protocols_from_rr(rr)
      alpn_param = rr.params[1]&.protocol_ids
      no_default_alpn = rr.params[2]

      svcb_alpn_set =
        if alpn_param.nil?
          DEFAULT_ALPN
        elsif no_default_alpn
          alpn_param
        else
          (alpn_param + DEFAULT_ALPN).uniq
        end

      svcb_alpn_set & SUPPORTED_PROTOCOLS
    end

    def synthesize_with_nat64_prefix(addr)
      ipv4_int = IPAddr.new_ntoh(addr.address).to_i
      AddrInt.synthesize(ipv4_int, @nat64_prefix).to_ipaddr
    end

    def precedences
      if @last_type == AAAA_TYPE then PRIORITY_ON_V4
      elsif @last_type == A_TYPE || @last_type.nil? then PRIORITY_ON_V6
      end
    end

    def address_available?(data, type)
      data[type]&.any? || data[HTTPS_TYPE]&.dig(type)&.any?
    end
  end

  class AddrInt
    def self.synthesize(ipv4_int, nat64_prefix_str)
      prefix_addr, prefix_len_str = nat64_prefix_str.split("/")
      prefix_len = prefix_len_str.to_i
      prefix_int = IPAddr.new(prefix_addr).to_i

      ipv6_int = case prefix_len
      when 96 then prefix_int | ipv4_int
      when 64 then prefix_int | (ipv4_int << 24)
      when 56 then prefix_int | (((ipv4_int >> 24) & 0xff) << 64) | ((ipv4_int & 0xffffff) << 32)
      when 48 then prefix_int | (((ipv4_int >> 16) & 0xffff) << 64) | ((ipv4_int & 0xffff) << 40)
      when 40 then prefix_int | (((ipv4_int >> 8) & 0xffffff) << 64) | ((ipv4_int & 0xff) << 48)
      when 32 then prefix_int | (ipv4_int << 64)
      end

      new(ipv6_int)
    end

    def initialize(int)
      @int = int
    end

    def to_ipaddr
      IPAddr.new(@int, Socket::AF_INET6)
    end

    def u_octet_zero?
      ((@int >> 56) & 0xff).zero?
    end

    def embedded_ipv4(prefix_len)
      case prefix_len
      when 96 then @int & 0xffffffff
      when 64 then (@int >> 24) & 0xffffffff
      when 56 then (((@int >> 64) & 0xff) << 24) | ((@int >> 32) & 0xffffff)
      when 48 then (((@int >> 64) & 0xffff) << 16) | ((@int >> 40) & 0xffff)
      when 40 then (((@int >> 64) & 0xffffff) << 8) | ((@int >> 48) & 0xff)
      when 32 then (@int >> 64) & 0xffffffff
      end
    end

    def label(prefix_len)
      "#{IPAddr.new(nat64_prefix(prefix_len), Socket::AF_INET6)}/#{prefix_len}"
    end

    private

    def nat64_prefix(prefix_len)
      shift = 128 - prefix_len
      (@int >> shift) << shift
    end
  end

  private_constant :AddrInt
end

HTTPClient.run
