require "socket"
require "resolv"
require "openssl"
require "ipaddr"
require "http/2"

require_relative "./getaddrinfo"

DEBUG = true

class HTTPClient
  AAAA_TYPE  = Resolv::DNS::Resource::IN::AAAA
  A_TYPE     = Resolv::DNS::Resource::IN::A
  HTTPS_TYPE = Resolv::DNS::Resource::IN::HTTPS
  NAT64_PREFIX_RESULT = :nat64_prefix_detected

  NAMESERVER = ["127.0.0.1", 5300]
  HOST = "localhost"
  HTTPS_PORT = 8443
  HTTP_PORT = 8080
  RESOLUTION_DELAY = 0.05
  CONNECTION_ATTEMPT_DELAY = 0.25

  def self.run
    self.new.run
  end

  def initialize
    @use_ssl = ARGV[0] == "https"
    @port = @use_ssl ? HTTPS_PORT : HTTP_PORT

    @resolver = Resolv::DNS.new(nameserver_port: [NAMESERVER])
    @record_types = record_types

    @nat64_discovery = NAT64PrefixDiscovery.new(resolver: @resolver)

    @hostname_resolution_result = HostnameResolutionResult.new
    @address_candidate_list = AddressCandidateList.new(@record_types, self)
    @hostname_resolution_threads = []
    @address_query_hostnames = []
    @connecting_sockets = {}
    @tls_handshaking_sockets = {}
    @connected_socket = nil
    @tls_connected_socket = nil

    @first_connection_attempted = false
    @resolution_delay_expires_at = nil
    @connection_attempt_delay_expires_at = nil
  end

  def run
    now = current_clock_time

    @record_types.each do |type|
      resolve_hostname_asynchronously!(type)
    end
    resolve_nat64_prefix_asynchronously! if address_synthesis_needed?

    count = 0 if DEBUG
    last_error = nil

    loop do
      count += 1 if DEBUG

      puts "[DEBUG] #{count}: ** Check for readying to connect **" if DEBUG
      puts "[DEBUG] #{count}: @address_candidate_list #{@address_candidate_list.instance_variable_get(:@candidates)}" if DEBUG
      puts "[DEBUG] #{count}: resolution_delay_expires_at #{@resolution_delay_expires_at}" if DEBUG

      if @address_candidate_list.any?
          && !@resolution_delay_expires_at
          && !@connection_attempt_delay_expires_at
        @first_connection_attempted = true
        ctx, address, _hostname, port = @address_candidate_list.next_candidate
        addrinfo = Addrinfo.tcp(address.to_s, port || @port)

        if !@use_ssl &&
            @address_candidate_list.empty? &&
            @connecting_sockets.empty? &&
            !@hostname_resolution_result.pending?
          begin
            @connected_socket = addrinfo.connect
            break
          rescue SystemCallError => e
            last_error = e
            raise last_error
          end
        else
          socket = Socket.new(addrinfo.afamily, Socket::SOCK_STREAM)
          begin
            socket.connect_nonblock(addrinfo)
            if @use_ssl
              if (error = nonblocking_connect_with_tls(socket, ctx))
                last_error = error
                @connection_attempt_delay_expires_at = nil
                next
              end
              break if @tls_connected_socket

              @connection_attempt_delay_expires_at = now + CONNECTION_ATTEMPT_DELAY
            else
              @connected_socket = socket
              break
            end
          rescue IO::WaitWritable
            @connection_attempt_delay_expires_at = now + CONNECTION_ATTEMPT_DELAY
            @connecting_sockets[socket] = [ctx, addrinfo]
          rescue SystemCallError => e
            socket.close
            last_error = e
            # この時点で待機対象のIOがない場合無期限に待機する可能性があるため、
            # 未試行の候補がある場合は待機せずに次のアドレスを試す
            next if @address_candidate_list.any?
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

      waiting_rfds = (@hostname_resolution_result.notifier || []) +
        @tls_handshaking_sockets.select { |_, direction| direction == :read }.keys
      waiting_wfds = @connecting_sockets.keys +
        @tls_handshaking_sockets.select { |_, direction| direction == :write }.keys

      if waiting_rfds.empty? && waiting_wfds.empty?
        # No delay remains: try the next candidate without waiting for IO.
        next if ends_at.nil?

        if ends_at == Float::INFINITY
          raise last_error || SocketError.new("no addresses resolved for #{HOST}")
        end
      end

      readable_fds, writable_fds, _ = IO.select(
        waiting_rfds, waiting_wfds, nil, second_to_timeout(current_clock_time, ends_at),
      )

      now = current_clock_time
      @resolution_delay_expires_at = nil if expired?(now, @resolution_delay_expires_at)
      @connection_attempt_delay_expires_at = nil if expired?(now, @connection_attempt_delay_expires_at)

      puts "[DEBUG] #{count}: ** Check for writable_fds **" if DEBUG
      puts "[DEBUG] #{count}: writable_fds #{writable_fds || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: connecting_sockets #{@connecting_sockets}" if DEBUG

      ssl_writable_sockets, writable_fds = (writable_fds || []).partition { @tls_handshaking_sockets.key?(it) }

      if writable_fds.any?
        while (writable_socket = writable_fds.pop)
          is_connected = (
            sockopt = writable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)
            sockopt.int.zero?
          )

          if is_connected
            ctx, _ = @connecting_sockets.delete(writable_socket)

            if @use_ssl
              if (error = nonblocking_connect_with_tls(writable_socket, ctx))
                last_error = error
                @connection_attempt_delay_expires_at = nil
              end

              break if @tls_connected_socket
            else
              @connected_socket = writable_socket
              break
            end
          else
            _, failed_ai = @connecting_sockets.delete writable_socket
            writable_socket.close
            ip_address = failed_ai.ipv6? ? "[#{failed_ai.ip_address}]" : failed_ai.ip_address
            last_error = SystemCallError.new("connect(2) for #{ip_address}:#{failed_ai.ip_port}", sockopt.int)

            if writable_fds.any? || @connecting_sockets.any? || @tls_handshaking_sockets.any?
              # Try other writable socket
            elsif @address_candidate_list.any? || @hostname_resolution_result.pending?
              @connection_attempt_delay_expires_at = nil
            else
              raise last_error
            end
          end
        end
      end

      ssl_ready_sockets, hostname_resolved = (readable_fds || []).partition { @tls_handshaking_sockets.key?(it) }

      (ssl_ready_sockets + ssl_writable_sockets).uniq.each do |ssl_socket|
        break if @tls_connected_socket

        if (error = advance_tls_handshake(ssl_socket))
          last_error = error
          @connection_attempt_delay_expires_at = nil
        end
      end

      if last_error && !@connected_socket && !@tls_connected_socket &&
          @tls_handshaking_sockets.empty? && @connecting_sockets.empty? &&
          !@address_candidate_list.any? && !@hostname_resolution_result.pending?
        raise last_error
      end

      puts "[DEBUG] #{count}: ** Check for hostname resolution finish **" if DEBUG
      puts "[DEBUG] #{count}: hostname_resolved #{hostname_resolved}" if DEBUG
      if hostname_resolved.any?
        while (result = @hostname_resolution_result.get)
          if result.type == NAT64_PREFIX_RESULT
            resolve_hostname_with_nat64_prefix_asynchronously!(result.success? ? result.records.first : nil)
          else
            @address_candidate_list.add(result)
            last_error = result.error unless result.success?
          end
        end
        @hostname_resolution_result.close_if_done

        if @address_candidate_list.any?
          if @address_candidate_list.all_resolved? ||
              (@address_candidate_list.resolved?(HTTPS_TYPE) &&
               @address_candidate_list.resolved?(@address_candidate_list.preferred_type))
            puts "[DEBUG] #{count}: Ready to start connecting" if DEBUG
            @resolution_delay_expires_at = nil
          elsif @resolution_delay_expires_at.nil? && !@first_connection_attempted
            puts "[DEBUG] #{count}: Resolution Delay is ready" if DEBUG
            @resolution_delay_expires_at = now + RESOLUTION_DELAY
          end
        end
      end

      puts "------------------------" if DEBUG

      break if @connected_socket || @tls_connected_socket
    end

    cancel_pending_operations

    socket = @tls_connected_socket || @connected_socket
    request(socket)
  ensure
    cancel_pending_operations
    close_socket(@tls_connected_socket)
    close_socket(@connected_socket)
  end

  def resolve_hostname_asynchronously!(type, hostname = HOST)
    if address_synthesis_needed?
      if [AAAA_TYPE, A_TYPE].include?(type) && !@address_query_hostnames.include?(hostname)
        @address_query_hostnames << hostname
      end
    end
    @hostname_resolution_result.count_up

    thread = Thread.new(type) do |type|
      records =
        if hostname == HOST && [AAAA_TYPE, A_TYPE].include?(type)
          initial_getresources(type)
        else
          @resolver.getresources(hostname, type)
        end

      @hostname_resolution_result.add(type, hostname, records:)
    rescue => e
      @hostname_resolution_result.add(type, hostname, error: e)
    end

    Thread.pass
    @hostname_resolution_threads.push(thread)
  end

  private

  def resolve_nat64_prefix_asynchronously!
    # Keep the result notifier open even if all destination queries finish first.
    @hostname_resolution_result.count_up

    thread = Thread.new do
      prefix = detect_nat64_prefix!
      @hostname_resolution_result.add(NAT64_PREFIX_RESULT, "ipv4only.arpa", records: [prefix])
    rescue => e
      @hostname_resolution_result.add(NAT64_PREFIX_RESULT, "ipv4only.arpa", error: e)
    end

    Thread.pass
    @hostname_resolution_threads.push(thread)
  end

  def resolve_hostname_with_nat64_prefix_asynchronously!(prefix)
    return unless prefix

    @address_candidate_list.nat64_prefix = prefix
    @record_types << A_TYPE unless @record_types.include?(A_TYPE)

    @address_query_hostnames.each do |hostname|
      resolve_hostname_asynchronously!(A_TYPE, hostname)
    end
  end

  def request(socket)
    protocol = @use_ssl ? socket.alpn_protocol : nil

    case protocol
    when "h2"
      request_http2(socket)
    when nil, "http/1.1"
      request_http1(socket)
    else
      raise IOError, "unsupported negotiated ALPN: #{protocol}"
    end
  end

  def request_http1(socket)
    request_message = "GET / HTTP/1.1\r\nHost: #{HOST}\r\nConnection: close\r\n\r\n"
    socket.write request_message

    response_message = socket.read
    status_line, *rest = response_message.split("\r\n")
    _, body = rest.join("\r\n").split("\r\n\r\n", 2)

    puts status_line
    puts body
  end

  def request_http2(socket)
    connection = HTTP2::Client.new
    connection.on(:frame) { |bytes| socket.write(bytes) }

    stream = connection.new_stream
    status = nil
    body = "".b
    completed = false
    stream_error = nil
    goaway_error = nil

    stream.on(:headers) do |headers|
      response_status = headers.to_h[":status"]
      status = response_status if response_status && !response_status.start_with?("1")
    end

    stream.on(:data) { |chunk| body << chunk }

    stream.on(:close) do |error|
      stream_error = error
      completed = true
    end

    connection.on(:goaway) do |last_stream, error, _payload|
      next if completed

      if error != :no_error || stream.id > last_stream
        goaway_error ||= IOError.new("HTTP/2 GOAWAY: #{error}, last_stream=#{last_stream}, stream=#{stream.id}")
      end
    end

    stream.headers({
      ":method"    => "GET",
      ":scheme"    => "https",
      ":authority" => "#{HOST}:#{@port}",
      ":path"      => "/",
    }, end_stream: true)

    until completed || goaway_error
      connection << socket.readpartial(16_384)
    end

    raise goaway_error if goaway_error
    raise IOError, "HTTP/2 stream failed: #{stream_error}" if stream_error
    raise IOError, "HTTP/2 response missing final status" unless status

    puts "HTTP/2 #{status}"
    puts body
  end

  def close_socket(socket)
    socket.close if socket && !socket.closed?
  rescue IOError, SystemCallError, OpenSSL::SSL::SSLError
    # Continue cleanup without replacing the original connection/request error.
    nil
  end

  def cancel_pending_operations
    [@connecting_sockets, @tls_handshaking_sockets].each do |connections|
      connections.each_key do |socket|
        close_socket(socket)
      end
      connections.clear
    end

    @hostname_resolution_threads.each(&:exit)
    @hostname_resolution_threads.each(&:join)
    @hostname_resolution_result.close_all
  end

  def initial_getresources(type)
    family = type == AAAA_TYPE ? Socket::AF_INET6 : Socket::AF_INET

    Addrinfo.getaddrinfo(HOST, @port, family, :STREAM).filter_map {
      type.new(it.ip_address) if !it.ipv6_linklocal?
    }.uniq
  end

  def record_types
    if ipv6_reachable? && ipv4_reachable?
      [HTTPS_TYPE, AAAA_TYPE, A_TYPE]
    elsif ipv6_reachable?
      [HTTPS_TYPE, AAAA_TYPE]
    elsif ipv4_reachable?
      [HTTPS_TYPE, A_TYPE]
    else
      raise "no network connectivity"
    end
  end

  def address_synthesis_needed?
    ipv6_reachable? && !ipv4_reachable?
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

  def detect_nat64_prefix!
    @nat64_discovery.discover!
  rescue Resolv::ResolvError, Resolv::ResolvTimeout
    nil
  end

  def nonblocking_connect_with_tls(tcp_socket, ctx)
    ssl_socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ctx)
    ssl_socket.sync_close = true
    # RFC 9460 Section 9.4: SNI identifies the origin, not the TargetName.
    ssl_socket.hostname = HOST

    advance_tls_handshake(ssl_socket)
  rescue OpenSSL::SSL::SSLError, SystemCallError => e
    close_socket(ssl_socket)
    close_socket(tcp_socket)
    e
  end

  # Return nil on success or IO wait, and the exception on failure.
  def advance_tls_handshake(ssl_socket)
    ssl_socket.connect_nonblock
    @tls_handshaking_sockets.delete(ssl_socket)
    @tls_connected_socket = ssl_socket
    nil
  rescue IO::WaitReadable
    @tls_handshaking_sockets[ssl_socket] = :read
    nil
  rescue IO::WaitWritable
    @tls_handshaking_sockets[ssl_socket] = :write
    nil
  rescue OpenSSL::SSL::SSLError, SystemCallError => e
    @tls_handshaking_sockets.delete(ssl_socket)
    close_socket(ssl_socket)
    e
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

    def pending?
      @taken_count < @size
    end

    def add(type, hostname, records: [], error: nil)
      @mutex.synchronize do
        @results.push ResolutionResult.new(type:, hostname:, records:, error:)
        @wpipe.putc(HOSTNAME_RESOLUTION_QUEUE_UPDATED) unless @wpipe.closed?
      rescue Errno::EPIPE
        # rpipe is closed
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

    def close_all
      @rpipe.close
      @notifier = nil
      @wpipe.close
    end
  end

  class NAT64PrefixDiscovery
    WELL_KNOWN_IPV4_ADDRESSES = [
      IPAddr.new("192.0.0.170").to_i,
      IPAddr.new("192.0.0.171").to_i,
    ].freeze
    NAT64_PREFIX_LENGTHS = [32, 40, 48, 56, 64, 96].freeze

    attr_reader :prefix

    def initialize(resolver:)
      @resolver = resolver
      @prefix = nil
    end

    def discover!
      records = @resolver.getresources("ipv4only.arpa", AAAA_TYPE)
      @prefix = extract_prefix!(records)
    end

    private

    def extract_prefix!(records)
      addresses = records.map { |rr|
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
    end
  end

  class AddressCandidateList
    PRIORITY_ON_V6 = [AAAA_TYPE, A_TYPE]
    PRIORITY_ON_V4 = [A_TYPE, AAAA_TYPE]
    SUPPORTED_PROTOCOLS = ["h2", "http/1.1"].freeze
    DEFAULT_ALPN = ["http/1.1"].freeze
    MAX_ALIAS_REDIRECTS = 8 # RFC 9460

    AddressCandidate = Data.define(:rr, :ctx, :ipv6_address_hints, :ipv4_address_hints)

    def initialize(record_types, client, nat64_prefix: nil)
      @record_types = record_types
      @candidates = {}
      @resolved_addresses = {}
      @resolved_types = Set.new
      @last_type = nil
      @client = client
      @nat64_prefix = nat64_prefix
      @pending_ipv4_hints = {}
      @resolved_ipv4_hostnames = Set.new
      @alias_redirect_count = 0
      @queried_hostnames = [HOST]
    end

    def nat64_prefix=(prefix)
      return if prefix.nil? || prefix == @nat64_prefix

      @nat64_prefix = prefix
      @pending_ipv4_hints.each do |key, hints|
        data = @candidates.fetch(key)
        data[HTTPS_TYPE][A_TYPE] = hints.map { |hint| synthesize_with_nat64_prefix(hint) }
        @resolved_types << A_TYPE if hints.any?
      end
      @pending_ipv4_hints.clear
    end

    def add(result)
      if result.type == HTTPS_TYPE
        if result.records.empty?
          @resolved_types << HTTPS_TYPE
          return
        end

        # RFC 9460 Section 2.4.1: if the RRset contains any AliasMode record,
        # all ServiceMode records in the same set MUST be ignored.
        # Section 2.4.2: if multiple AliasMode records are present, pick one at random.
        alias_record = result.records.select(&:alias_mode?).sample

        if alias_record
          resolve_alias!(alias_record)
          return
        end

        supported_records = result.records.map { |rr| create_address_candidate_from_rr!(rr) }.compact
        @resolved_types << HTTPS_TYPE
        return if supported_records.empty?

        sorted_candidates = supported_records.sort_by { |c| c.rr.priority }

        sorted_candidates.each do |candidate|
          target_name = candidate.rr.target.to_s
          hostname = target_name.empty? ? result.hostname : target_name
          priority = candidate.rr.priority

          @candidates.delete([hostname, Float::INFINITY])
          resolved = @resolved_addresses.fetch(hostname, {})

          synthesized_ipv4_hints = @nat64_prefix ?
            candidate.ipv4_address_hints.map { |hint| synthesize_with_nat64_prefix(hint) } :
            candidate.ipv4_address_hints

          # 対応していないアドレスファミリ (接続性のない側) のヒントはアドレスリストから除外する
          ipv6_hints = @record_types.include?(AAAA_TYPE) ? candidate.ipv6_address_hints : []
          ipv4_hints = (@nat64_prefix || @record_types.include?(A_TYPE)) ? synthesized_ipv4_hints : []

          key = [hostname, priority, candidate.rr]
          @pending_ipv4_hints.delete(key)

          if @resolved_ipv4_hostnames.include?(hostname)
            ipv4_hints = []
          elsif !@nat64_prefix && !@record_types.include?(A_TYPE)
            # Retain unusable hints separately until a prefix is supplied.
            @pending_ipv4_hints[key] = candidate.ipv4_address_hints
          end

          @candidates[key] = {
            AAAA_TYPE => resolved.fetch(AAAA_TYPE, []).dup,
            A_TYPE    => resolved.fetch(A_TYPE, []).dup,
            HTTPS_TYPE  => {
              AAAA_TYPE => resolved.key?(AAAA_TYPE) ? [] : ipv6_hints.dup,
              A_TYPE    => resolved.key?(A_TYPE) ? [] : ipv4_hints.dup,
            },
            :ctx  => candidate.ctx,
            :port => candidate.rr.params[3]&.port,
          }

          # HEv3 draft Section 4.2.1: address hints in ServiceMode records SHOULD be
          # treated as positive answers until the real AAAA/A records arrive.
          @resolved_types << AAAA_TYPE if ipv6_hints.any?
          @resolved_types << A_TYPE if ipv4_hints.any?

          if !@queried_hostnames.include?(hostname)
            @queried_hostnames << hostname
            @client.resolve_hostname_asynchronously!(AAAA_TYPE, hostname) if @record_types.include?(AAAA_TYPE)
            @client.resolve_hostname_asynchronously!(A_TYPE, hostname) if @record_types.include?(A_TYPE)
          end
        end
      elsif result.success?
        if result.type == A_TYPE
          @resolved_ipv4_hostnames << result.hostname
          @pending_ipv4_hints.delete_if { |(hostname, _), _hints| hostname == result.hostname }
        end

        addresses = result.type == A_TYPE && @nat64_prefix ?
          result.records.map { |rr| synthesize_with_nat64_prefix(rr.address) } :
          result.records.map(&:address)

        (@resolved_addresses[result.hostname] ||= {})[result.type] = addresses

        keys = @candidates.keys.select { |(hostname, _priority)| hostname == result.hostname }
        keys = [[result.hostname, Float::INFINITY]] if keys.empty?

        keys.each do |key|
          @candidates[key] ||= { AAAA_TYPE => [], A_TYPE => [], ctx: default_ctx }
          @candidates[key][result.type] = addresses.dup
          @candidates[key][HTTPS_TYPE]&.delete(result.type)
        end
      end

      @resolved_types << result.type
    end

    def next_candidate
      @candidates
        .group_by { |(_hostname, priority), _| priority }
        .sort_by { |priority, _entries| priority }
        .each do |_priority, entries|
          precedences.each do |type|
            candidates = entries.select { |_priority, data| address_available?(data, type) }
            next if candidates.empty?

            (hostname, _priority), data = candidates.to_a.sample
            address = data[type]&.shift || data[HTTPS_TYPE]&.dig(type)&.shift
            @last_type = type
            return [data[:ctx], address, hostname, data[:port]]
          end
        end

      nil
    end

    def resolved?(type)
      @resolved_types.include?(type)
    end

    def all_resolved?
      @record_types.all? { |type| resolved?(type) }
    end

    def preferred_type
      @record_types.include?(AAAA_TYPE) ? AAAA_TYPE : A_TYPE
    end

    def empty?
      @candidates.none? { |_, data| [AAAA_TYPE, A_TYPE].any? { |type| address_available?(data, type) } }
    end

    def any?
      !empty?
    end

    private

    def resolve_alias!(alias_record)
      @alias_redirect_count += 1

      if @alias_redirect_count <= MAX_ALIAS_REDIRECTS
        @client.resolve_hostname_asynchronously!(HTTPS_TYPE, alias_record.target.to_s)
      else
        @resolved_types << HTTPS_TYPE # HTTPSは解決済みとしてA/AAAAへフォールバック
      end
    end

    def default_ctx
      ctx = ::OpenSSL::SSL::SSLContext.new
      ctx.alpn_protocols = SUPPORTED_PROTOCOLS
      ctx
    end

    def create_address_candidate_from_rr!(rr)
      return if extract_alpn_protocols_from_rr(rr).empty?

      ctx = default_ctx
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
      elsif @last_type == A_TYPE then PRIORITY_ON_V6
      elsif preferred_type == AAAA_TYPE then PRIORITY_ON_V6
      else PRIORITY_ON_V4
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
