require 'socket'

class Socket
  DEBUG = true

  RESOLUTION_DELAY = 0.05
  private_constant :RESOLUTION_DELAY

  CONNECTION_ATTEMPT_DELAY = 0.25
  private_constant :CONNECTION_ATTEMPT_DELAY

  ADDRESS_FAMILIES = {
    ipv6: Socket::AF_INET6,
    ipv4: Socket::AF_INET
  }.freeze
  private_constant :ADDRESS_FAMILIES

  HOSTNAME_RESOLUTION_QUEUE_UPDATED = 0
  private_constant :HOSTNAME_RESOLUTION_QUEUE_UPDATED

  IPV6_ADRESS_FORMAT = /\A(?i:(?:(?:[0-9A-F]{1,4}:){7}(?:[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){6}(?:[0-9A-F]{1,4}|:(?:[0-9A-F]{1,4}:){1,5}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){5}(?:(?::[0-9A-F]{1,4}){1,2}|:(?:[0-9A-F]{1,4}:){1,4}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){4}(?:(?::[0-9A-F]{1,4}){1,3}|:(?:[0-9A-F]{1,4}:){1,3}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){3}(?:(?::[0-9A-F]{1,4}){1,4}|:(?:[0-9A-F]{1,4}:){1,2}[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){2}(?:(?::[0-9A-F]{1,4}){1,5}|:(?:[0-9A-F]{1,4}:)[0-9A-F]{1,4}|:)|(?:[0-9A-F]{1,4}:){1}(?:(?::[0-9A-F]{1,4}){1,6}|:(?:[0-9A-F]{1,4}:){0,5}[0-9A-F]{1,4}|:)|(?:::(?:[0-9A-F]{1,4}:){0,7}[0-9A-F]{1,4}|::)))(?:%.+)?\z/
  private_constant :IPV6_ADRESS_FORMAT

  @tcp_fast_fallback = true

  class << self
    attr_accessor :tcp_fast_fallback
  end

  def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, fast_fallback: tcp_fast_fallback, &block) # :yield: socket
    sock = if fast_fallback && !(host && ip_address?(host))
      tcp_with_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    else
      tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    end

    if block_given?
      begin
        yield sock
      ensure
        sock.close
      end
    else
      sock
    end
  end

  def self.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil)
    if local_host || local_port
      local_addrinfos = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, timeout: resolv_timeout)
      resolving_family_names = local_addrinfos.map { |lai| ADDRESS_FAMILIES.key(lai.afamily) }.uniq
    else
      local_addrinfos = []
      resolving_family_names = ADDRESS_FAMILIES.keys
    end

    hostname_resolution_threads = []
    resolution_store = HostnameResolutionStore.new(resolving_family_names)
    connecting_sockets = {}
    is_windows_environment ||= (RUBY_PLATFORM =~ /mswin|mingw|cygwin/)

    now = current_clock_time
    resolution_delay_expires_at = nil
    connection_attempt_delay_expires_at = nil
    user_specified_connect_timeout_at = nil
    last_error = nil

    if resolving_family_names.size == 1
      family_name = resolving_family_names.first
      addrinfos = Addrinfo.getaddrinfo(host, port, family_name, :STREAM, timeout: resolv_timeout)
      resolution_store.add_resolved(family_name, addrinfos)
      hostname_resolution_result = nil
      hostname_resolution_notifier = nil
      user_specified_resolv_timeout_at = nil
    else
      hostname_resolution_result = HostnameResolutionResult.new(resolving_family_names.size)
      hostname_resolution_notifier = hostname_resolution_result.notifier

      hostname_resolution_threads.concat(
        resolving_family_names.map { |family|
          thread_args = [family, host, port, hostname_resolution_result]
          thread = Thread.new(*thread_args) { |*thread_args| resolve_hostname(*thread_args) }
          Thread.pass
          thread
        }
      )

      user_specified_resolv_timeout_at = resolv_timeout ? now + resolv_timeout : 0
    end

    count = 0 if DEBUG # for DEBUGging

    loop do
      count += 1 if DEBUG # for DEBUGging

      puts "[DEBUG] #{count}: ** Check for readying to connect **" if DEBUG
      puts "[DEBUG] #{count}: resolution_store #{resolution_store.instance_variable_get(:"@addrinfo_dict")}" if DEBUG
      puts "[DEBUG] #{count}: user_specified_connect_timeout_at #{user_specified_connect_timeout_at}" if DEBUG
      puts "[DEBUG] #{count}: resolution_delay_expires_at #{resolution_delay_expires_at}" if DEBUG

      if resolution_store.any_addrinfos? &&
          !resolution_delay_expires_at &&
          !connection_attempt_delay_expires_at

        puts "[DEBUG] #{count}: ** Start to connect **" if DEBUG
        puts "[DEBUG] #{count}: resolution_store #{resolution_store.instance_variable_get(:"@addrinfo_dict")}"  if DEBUG
        while (addrinfo = resolution_store.get_addrinfo)
          puts "[DEBUG] #{count}: Get #{addrinfo.ip_address} as a destination address" if DEBUG

          if local_addrinfos.any?
            puts "[DEBUG] #{count}: local_addrinfos #{local_addrinfos}" if DEBUG
            local_addrinfo = local_addrinfos.find { |lai| lai.afamily == addrinfo.afamily }

            if local_addrinfo.nil? # Connecting addrinfoと同じアドレスファミリのLocal addrinfoがない
              if resolution_store.any_addrinfos?
                # Try other Addrinfo in next "while"
                next
              elsif connecting_sockets.any? || resolution_store.any_unresolved_family?
                # Exit this "while" and wait for connections to be established or hostname resolution in next loop
                # Or exit this "while" and wait for hostname resolution in next loop
                break
              else
                raise SocketError.new 'no appropriate local address'
              end
            end
          end

          puts "[DEBUG] #{count}: Start to connect to #{addrinfo.ip_address}" if DEBUG

          begin
            if resolution_store.any_addrinfos? ||
               connecting_sockets.any? ||
               resolution_store.any_unresolved_family?
              socket = Socket.new(addrinfo.pfamily, addrinfo.socktype, addrinfo.protocol)
              socket.bind(local_addrinfo) if local_addrinfo
              result = socket.connect_nonblock(addrinfo, exception: false)
            else
              result = socket = local_addrinfo ?
                addrinfo.connect_from(local_addrinfo, timeout: connect_timeout) :
                addrinfo.connect(timeout: connect_timeout)
            end

            if result == :wait_writable
              connection_attempt_delay_expires_at = now + CONNECTION_ATTEMPT_DELAY
              if resolution_store.empty_addrinfos?
                user_specified_connect_timeout_at = connect_timeout ? now + connect_timeout : 0
              end

              connecting_sockets[socket] = addrinfo
              break
            else
              return socket # connection established
            end
          rescue SystemCallError => e
            socket&.close
            last_error = e

            if resolution_store.any_addrinfos?
              # Try other Addrinfo in next "while"
              next
            elsif connecting_sockets.any? || resolution_store.any_unresolved_family?
              # Exit this "while" and wait for connections to be established or hostname resolution in next loop
              # Or exit this "while" and wait for hostname resolution in next loop
              break
            else
              raise last_error
            end
          end
        end
      end

      puts "[DEBUG] #{count}: connecting_sockets #{connecting_sockets}" if DEBUG
      puts "[DEBUG] #{count}: last error #{last_error&.message|| 'nil'}" if DEBUG

      ends_at =
        if resolution_store.any_addrinfos?
          resolution_delay_expires_at || connection_attempt_delay_expires_at
        else
          [user_specified_resolv_timeout_at, user_specified_connect_timeout_at].compact.max
        end

      puts "[DEBUG] #{count}: resolution_delay_expires_at #{resolution_delay_expires_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: connection_attempt_delay_expires_at #{connection_attempt_delay_expires_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: user_specified_resolv_timeout_at #{user_specified_resolv_timeout_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: user_specified_connect_timeout_at #{user_specified_connect_timeout_at || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: ends_at #{ends_at || 'nil'}" if DEBUG

      puts "[DEBUG] #{count}: ** Start to wait **" if DEBUG
      puts "[DEBUG] #{count}: IO.select(#{hostname_resolution_notifier}, #{connecting_sockets.keys}, nil, #{second_to_timeout(current_clock_time, ends_at)})" if DEBUG
      hostname_resolved, writable_sockets, = IO.select(
        hostname_resolution_notifier,
        connecting_sockets.keys,
        nil,
        second_to_timeout(current_clock_time, ends_at),
      )
      now = current_clock_time
      resolution_delay_expires_at = nil if expired?(now, resolution_delay_expires_at)
      connection_attempt_delay_expires_at = nil if expired?(now, connection_attempt_delay_expires_at)

      if is_windows_environment
        connecting_sockets.each do |connecting_socket, _|
          sockopt = connecting_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_CONNECT_TIME)
          connecting_sockets.delete(connecting_socket) if sockopt.unpack('i').first < 0
        end
      end

      puts "[DEBUG] #{count}: ** Check for writable_sockets **" if DEBUG
      puts "[DEBUG] #{count}: writable_sockets #{writable_sockets || 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: connecting_sockets #{connecting_sockets}" if DEBUG

      if writable_sockets&.any?
        while (writable_socket = writable_sockets.pop)
          is_connected =
            if is_windows_environment
              sockopt = writable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_CONNECT_TIME)
              sockopt.unpack('i').first >= 0
            else
              sockopt = writable_socket.getsockopt(Socket::SOL_SOCKET, Socket::SO_ERROR)
              sockopt.int.zero?
            end

          if is_connected
            puts "[DEBUG] #{count}: Socket for #{writable_socket.remote_address.ip_address} is connected" if DEBUG
            connecting_sockets.delete writable_socket
            return writable_socket
          else
            failed_ai = connecting_sockets.delete writable_socket
            writable_socket.close

            if writable_sockets.any? ||
               resolution_store.any_addrinfos? ||
               connecting_sockets.any? ||
               resolution_store.any_unresolved_family?
              user_specified_connect_timeout_at = nil if connecting_sockets.empty?
              # Try other writable socket in next "while"
              # Or exit this "while" and try other connection attempt
              # Or exit this "while" and wait for connections to be established or hostname resolution in next loop
              # Or exit this "while" and wait for hostname resolution in next loop
            else
              ip_address = failed_ai.ipv6? ? "[#{failed_ai.ip_address}]" : failed_ai.ip_address
              last_error = SystemCallError.new("connect(2) for #{ip_address}:#{failed_ai.ip_port}", sockopt.int)
              raise last_error
            end
          end
        end
      end

      puts "[DEBUG] #{count}: last error #{last_error&.message|| 'nil'}" if DEBUG

      puts "[DEBUG] #{count}: ** Check for hostname resolution finish **" if DEBUG
      puts "[DEBUG] #{count}: hostname_resolved #{hostname_resolved || 'nil'}" if DEBUG
      if hostname_resolved&.any?
        while (family_and_result = hostname_resolution_result.get)
          family_name, result = family_and_result
          puts "[DEBUG] #{count}: family_name, result #{[family_name, result]}" if DEBUG

          if result.is_a? Exception
            resolution_store.add_error(family_name, result)

            unless (Socket.const_defined?(:EAI_ADDRFAMILY)) &&
              (result.is_a?(Socket::ResolutionError)) &&
              (result.error_code == Socket::EAI_ADDRFAMILY)
              last_error = result
            end
          else
            resolution_store.add_resolved(family_name, result)
          end
        end

        if resolution_store.resolved?(:ipv4)
          if resolution_store.resolved?(:ipv6)
            puts "[DEBUG] #{count}: All hostname resolution is finished" if DEBUG
            hostname_resolution_notifier = nil
            resolution_delay_expires_at = nil
            user_specified_resolv_timeout_at = nil
          elsif resolution_store.resolved_successfully?(:ipv4)
            puts "[DEBUG] #{count}: Resolution Delay is ready" if DEBUG
            resolution_delay_expires_at = now + RESOLUTION_DELAY
            puts "[DEBUG] #{count}: ends_at #{ends_at}" if DEBUG
          end
        end
      end

      puts "[DEBUG] #{count}: resolution_store #{resolution_store.instance_variable_get(:"@addrinfo_dict")}"  if DEBUG
      puts "[DEBUG] #{count}: user_specified_resolv_timeout_at #{user_specified_resolv_timeout_at|| 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: user_specified_connect_timeout_at #{user_specified_connect_timeout_at|| 'nil'}" if DEBUG
      puts "[DEBUG] #{count}: last error #{last_error&.message|| 'nil'}" if DEBUG

      if resolution_store.empty_addrinfos?
        if connecting_sockets.empty? && resolution_store.resolved_all_families?
          raise last_error
        end

        if (expired?(now, user_specified_resolv_timeout_at) || resolution_store.resolved_all_families?) &&
           (expired?(now, user_specified_connect_timeout_at) || connecting_sockets.empty?)
          raise Errno::ETIMEDOUT, 'user specified timeout'
        end
      end
      puts "------------------------" if DEBUG
    end
  ensure
    hostname_resolution_threads.each do |thread|
      thread.exit
    end

    hostname_resolution_result&.close

    connecting_sockets.each_key do |connecting_socket|
      connecting_socket.close
    end
  end

  def self.tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, &block)
    last_error = nil
    ret = nil

    local_addr_list = nil
    if local_host != nil || local_port != nil
      local_addr_list = Addrinfo.getaddrinfo(local_host, local_port, nil, :STREAM, nil)
    end

    Addrinfo.foreach(host, port, nil, :STREAM, timeout: resolv_timeout) {|ai|
      if local_addr_list
        local_addr = local_addr_list.find {|local_ai| local_ai.afamily == ai.afamily }
        next unless local_addr
      else
        local_addr = nil
      end
      begin
        sock = local_addr ?
          ai.connect_from(local_addr, timeout: connect_timeout) :
          ai.connect(timeout: connect_timeout)
      rescue SystemCallError
        last_error = $!
        next
      end
      ret = sock
      break
    }
    unless ret
      if last_error
        raise last_error
      else
        raise SocketError, "no appropriate local address"
      end
    end

    ret
  end
  private_class_method :tcp_without_fast_fallback

  def self.ip_address?(hostname)
    hostname.match?(IPV6_ADRESS_FORMAT) || hostname.match?(/\A([0-9]{1,3}\.){3}[0-9]{1,3}\z/)
  end
  private_class_method :ip_address?

  def self.resolve_hostname(family, host, port, hostname_resolution_result)
    begin
      resolved_addrinfos = Addrinfo.getaddrinfo(host, port, ADDRESS_FAMILIES[family], :STREAM)
      hostname_resolution_result.add(family, resolved_addrinfos)
    rescue => e
      hostname_resolution_result.add(family, e)
    end
  end
  private_class_method :resolve_hostname

  def self.current_clock_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
  private_class_method :current_clock_time

  def self.second_to_timeout(started_at, ends_at)
    return nil if ends_at.nil? || ends_at.zero?

    remaining = (ends_at - started_at)
    remaining.negative? ? 0 : remaining
  end
  private_class_method :second_to_timeout

  def self.expired?(started_at, ends_at)
    second_to_timeout(started_at, ends_at)&.zero?
  end
  private_class_method :expired?

  class HostnameResolutionResult
    def initialize(size)
      @size = size
      @taken_count = 0
      @rpipe, @wpipe = IO.pipe
      @results = []
      @mutex = Mutex.new
    end

    def notifier
      [@rpipe]
    end

    def add(family, result)
      @mutex.synchronize do
        @results.push [family, result]
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
      @wpipe.close
    end
  end
  private_constant :HostnameResolutionResult

  class HostnameResolutionStore
    PRIORITY_ON_V6 = [:ipv6, :ipv4]
    PRIORITY_ON_V4 = [:ipv4, :ipv6]

    def initialize(family_names)
      @family_names = family_names
      @addrinfo_dict = {}
      @error_dict = {}
      @last_family = nil
    end

    def add_resolved(family_name, addrinfos)
      @addrinfo_dict[family_name] = addrinfos
    end

    def add_error(family_name, error)
      @addrinfo_dict[family_name] = []
      @error_dict[family_name] = error
    end

    def get_addrinfo
      precedences =
        case @last_family
        when :ipv4, nil then PRIORITY_ON_V6
        when :ipv6      then PRIORITY_ON_V4
        end

      precedences.each do |family_name|
        addrinfo = @addrinfo_dict[family_name]&.shift
        next unless addrinfo

        @last_family = family_name
        return addrinfo
      end

      nil
    end

    def empty_addrinfos?
      @addrinfo_dict.all? { |_, addrinfos| addrinfos.empty? }
    end

    def any_addrinfos?
      !empty_addrinfos?
    end

    def resolved?(family)
      @addrinfo_dict.has_key? family
    end

    def resolved_successfully?(family)
      resolved?(family) && !!@error_dict[family]
    end

    def resolved_all_families?
      (@family_names - @addrinfo_dict.keys).empty?
    end

    def any_unresolved_family?
      !resolved_all_families?
    end
  end
  private_constant :HostnameResolutionStore
end

HOSTNAME = "localhost"
PORT = 9292

# HOSTNAME = "www.ruby-lang.org"
# PORT = 80

# # 名前解決動作確認用 (Connection Attempt Delay以内の遅延)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == Socket::AF_INET6
#     sleep 0.25
#     [Addrinfo.tcp("::1", PORT)]
#   else
#     [Addrinfo.tcp("127.0.0.1", PORT)]
#   end
# end

# # 名前解決動作確認用 (タイムアウト)
# Addrinfo.define_singleton_method(:getaddrinfo) { |*_| sleep }

# # 名前解決動作確認用 (例外)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == Socket::AF_INET6
#     [Addrinfo.tcp("::1", PORT)]
#   else
#     # NOTE ignoreされる
#     raise SocketError, 'getaddrinfo: Address family for hostname not supported'
#   end
# end

# # 名前解決動作確認用 (複数)
# Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
#   if family == Socket::AF_INET6
#     [Addrinfo.tcp("::1", PORT), Addrinfo.tcp("::1", PORT)]
#   else
#     sleep 0.1
#     [Addrinfo.tcp("127.0.0.1", PORT)]
#   end
# end

# # local_host / local_port を指定する場合
class Addrinfo
  class << self
    alias _getaddrinfo getaddrinfo

    def getaddrinfo(nodename, service, family, *_)
      if service == 9292
        if family == Socket::AF_INET6
          [Addrinfo.tcp("::1", 9292)]
        else
          [Addrinfo.tcp("127.0.0.1", 9292)]
        end
      else
        _getaddrinfo(nodename, service, family)
      end
    end
  end
end

local_ip = Socket.ip_address_list.detect { |addr| addr.ipv4? && !addr.ipv4_loopback? }.ip_address

Socket.tcp(HOSTNAME, PORT, local_ip, 0) do |socket|
   socket.write "GET / HTTP/1.0\r\n\r\n"
   print socket.read
end

# Socket.tcp(HOSTNAME, PORT, fast_fallback: false) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end

# Socket.tcp("::1", PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end

# Socket.tcp(HOSTNAME, PORT) do |socket|
#   socket.write "GET / HTTP/1.0\r\n\r\n"
#   print socket.read
# end

__END__

This is a proposed improvement to `Socket.tcp`, which has implemented Happy Eyeballs version 2 (RFC8305) in PR9374.

### Background
I implemented Happy Eyeballs version 2 (HEv2) for Socket.tcp in PR9374, but several issues have been identified:

- `IO.select` waits for both IPv6/IPv4 name resolution (in start), but when it returns a value, it doesn't consider the case where name resolution for both address families is complete.
  - In this case, `Socket.tcp` can only obtain the addresses of one address family and needs to execute an unnecessary loop to obtain the other addresses. In some cases, it may unnecessarily wait for 50ms (in v4w).
- `IO.select` waits for name resolution or connection establishment in v46w, but it does not consider the case where both events occur simultaneously when it returns a value.
  - In this case, Socket.tcp can only capture one event and needs to execute an unnecessary loop to capture the other one, calling `IO.select` one extra time.
- The consideration for `connect_timeout` was insufficient. After initiating one or more connections, it raises a 'user specified timeout' after the `connect_timeout` period even if there were addresses that have been resolved and have not yet tried to connect.
- It does not retry with another address in case of a connection failure.
- It executes unnecessary state transitions even when an IP address is passed as the `host` argument.
- The regex for IP addresses did not correctly specify the start and end.

### Proposal & Outcome
To overcome the aforementioned issues, this PR introduces the following changes:

- Previously, each loop iteration represented a single state transition. This has been changed to execute all processes that meet the execution conditions within a single loop iteration.
  - This prevents unnecessary repeated loops and calling `IO.select`
- Introduced logic to determine the timeout value set for `IO.select`. During the Resolution Delay and Connection Attempt Delay, the user-specified timeout is ignored. Otherwise, the timeout value is set to the larger of `resolv_timeout` and `connect_timeout`.
  - This ensures that the `connect_timeout` is only detected after attempting to connect to all resolved addresses.
- Retry with another address in case of a connection failure.
  - This prevents unnecessary repeated loops upon connection failure.
- Call `tcp_without_fast_fallback` when an IP address is passed as the host argument.
  - This prevents unnecessary state transitions when an IP address is passed.
- Fixed regex for IP addresses.

Additionally, the code has been reduced by over 100 lines, and redundancy has been minimized, which is expected to improve readability.

### Performance
No significant performance changes were observed in the happy case before and after the improvement.
However, improvements in state transition deficiencies are expected to enhance performance in edge cases.

```ruby
require 'socket'
require 'benchmark'

Benchmark.bmbm do |x|
  x.report('fast_fallback: true') do
    30.times { Socket.tcp("www.ruby-lang.org", 80) }
  end

  x.report('fast_fallback: false') do # Ruby3.3時点と同じ
    30.times { Socket.tcp("www.ruby-lang.org", 80, fast_fallback: false) }
  end
end
```

```
# Before
~/s/build ❯❯❯ ../install/bin/ruby ../ruby/test.rb

                           user     system      total        real
fast_fallback: true    0.021315   0.040723   0.062038 (  0.504866)
fast_fallback: false   0.007553   0.026248   0.033801 (  0.533211)
```

```
# After
~/s/build ❯❯❯ ../install/bin/ruby ../ruby/test.rb

                           user     system      total        real
fast_fallback: true    0.023081   0.040525   0.063606 (  0.406219)
fast_fallback: false   0.007302   0.025515   0.032817 (  0.418680)
```
