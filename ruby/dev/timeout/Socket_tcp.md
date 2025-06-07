```ruby
def self.tcp(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, open_timeout: nil, fast_fallback: tcp_fast_fallback, &) # :yield: socket

  if open_timeout && (connect_timeout || resolv_timeout)
    raise ArgumentError, "Cannot specify open_timeout along with connect_timeout or resolv_timeout"
  end

  sock = if fast_fallback && !(host && ip_address?(host))
   tcp_with_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, open_timeout:)
  else
   tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, open_timeout:)
  end

  # ...

end

def self.tcp_with_fast_fallback(host, port, local_host = nil, local_port = nil, connect_timeout: nil, resolv_timeout: nil, open_timeout: nil)
  # ...

  connection_attempt_delay_expires_at = nil
  user_specified_connect_timeout_at = nil
  user_specified_open_timeout_at = open_timeout ? now + open_timeout : nil

  # ...

  loop do
    # ...

    ends_at =
      if resolution_store.any_addrinfos?
        [(resolution_delay_expires_at || connection_attempt_delay_expires_at),
         user_specified_open_timeout_at].compact.min
      elsif user_specified_open_timeout_at
        user_specified_open_timeout_at
      else
        [user_specified_resolv_timeout_at, user_specified_connect_timeout_at].compact.max
      end

    # ...

    if resolution_store.empty_addrinfos?
      raise(Errno::ETIMEDOUT, 'user specified timeout') if expired?(now, user_specified_open_timeout_at)

      if connecting_sockets.empty? && resolution_store.resolved_all_families?
        # ...
      end
      # ...
    end
  end

  # ...

end

def self.tcp_without_fast_fallback(host, port, local_host, local_port, connect_timeout:, resolv_timeout:, open_timeout:)
  # ...

  timeout = open_timeout ? open_timeout : resolv_timeout
  starts_at = current_clock_time

  Addrinfo.foreach(host, port, nil, :STREAM, timeout:) {|ai|
    # ...
    begin
      timeout = open_timeout ? open_timeout - (current_clock_time - starts_at) : connect_timeout
      sock = local_addr ?
        ai.connect_from(local_addr, timeout:) :
        ai.connect(timeout:)
      # ...
    end
  }
  # ...
end
```

```ruby
# Addrinfo.getaddrinfoを直さないと期待通りに動作しない
def test_tcp_socket_open_timeout_without_fast_fallback
  opts = %w[-rsocket -W1]
  assert_separately opts, <<~RUBY
  Addrinfo.define_singleton_method(:getaddrinfo) { |*_| sleep }

  assert_raise(Errno::ETIMEDOUT) do
    Socket.tcp("localhost", 12345, open_timeout: 0.01, fast_fallback: false)
  end
  RUBY
end

def test_tcp_socket_open_timeout_with_other_timeouts
  opts = %w[-rsocket -W1]
  assert_separately opts, <<~RUBY
  assert_raise(ArgumentError) do
    Socket.tcp("localhost", 12345, open_timeout: 0.01, resolv_timout: 0.01)
  end
  RUBY
end
```
