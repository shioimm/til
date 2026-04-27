# `test/socket/test_tcp.rb`
- start -> v6c -> v46w -> success
- start -> v4w -> v4c -> v46w -> success
- start -> v6c -> v46w -> v4c -> v46w -> success
- start -> v4w -> v46c -> v46w -> success
- start -> v4w -> v4c -> v46w -> timeout (v46wで接続に失敗した後名前解決でタイムアウト)
- `fast_fallback`

```ruby
class TestSocket_TCPSocket < Test::Unit::TestCase
  # ...
  def test_initialize_v6_hostname_resolved_earlier
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    begin
      # Verify that "localhost" can be resolved to an IPv6 address
      Socket.getaddrinfo("localhost", 0, Socket::AF_INET6)
      server = TCPServer.new("::1", 0)
    rescue Socket::ResolutionError, Errno::EADDRNOTAVAIL # IPv6 is not supported
      return
    end

    server_thread = Thread.new { server.accept }
    port = server.addr[1]

    socket = TCPSocket.new(
      "localhost",
      port,
      fast_fallback: true,
      test_mode_settings: { delay: { ipv4: 1000 } }
    )
    assert_true(socket.remote_address.ipv6?)
  ensure
    server_thread&.value&.close
    server&.close
    socket&.close
  end

  def test_initialize_v4_hostname_resolved_earlier
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]

    server_thread = Thread.new { server.accept }
    socket = TCPSocket.new(
      "localhost",
      port,
      fast_fallback: true,
      test_mode_settings: { delay: { ipv6: 1000 } }
    )
    assert_true(socket.remote_address.ipv4?)
  ensure
    server_thread&.value&.close
    server&.close
    socket&.close
  end

  def test_initialize_v6_hostname_resolved_in_resolution_delay
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    begin
      # Verify that "localhost" can be resolved to an IPv6 address
      Socket.getaddrinfo("localhost", 0, Socket::AF_INET6)
      server = TCPServer.new("::1", 0)
    rescue Socket::ResolutionError, Errno::EADDRNOTAVAIL # IPv6 is not supported
      return
    end

    port = server.addr[1]
    delay_time = 25 # Socket::RESOLUTION_DELAY (private) is 50ms

    server_thread = Thread.new { server.accept }
    socket = TCPSocket.new(
      "localhost",
      port,
      fast_fallback: true,
      test_mode_settings: { delay: { ipv6: delay_time } }
    )
    assert_true(socket.remote_address.ipv6?)
  ensure
    server_thread&.value&.close
    server&.close
    socket&.close
  end

  def test_initialize_v6_hostname_resolved_earlier_and_v6_server_is_not_listening
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    ipv4_address = "127.0.0.1"
    server = Socket.new(Socket::AF_INET, :STREAM)
    server.bind(Socket.pack_sockaddr_in(0, ipv4_address))
    port = server.connect_address.ip_port

    server_thread = Thread.new { server.listen(1); server.accept }
    socket = TCPSocket.new(
      "localhost",
      port,
      fast_fallback: true,
      test_mode_settings: { delay: { ipv4: 10 } }
    )
    assert_equal(ipv4_address, socket.remote_address.ip_address)
  ensure
    accepted, _ = server_thread&.value
    accepted&.close
    server&.close
    socket&.close
  end

  def test_initialize_v6_hostname_resolved_later_and_v6_server_is_not_listening
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server = Socket.new(Socket::AF_INET, :STREAM)
    server.bind(Socket.pack_sockaddr_in(0, "127.0.0.1"))
    port = server.connect_address.ip_port

    server_thread = Thread.new { server.listen(1); server.accept }
    socket = TCPSocket.new(
      "localhost",
      port,
      fast_fallback: true,
      test_mode_settings: { delay: { ipv6: 25 } }
    )
    assert_true(socket.remote_address.ipv4?)
  ensure
    accepted, _ = server_thread&.value
    accepted&.close
    server&.close
    socket&.close
  end

  def test_initialize_v6_hostname_resolution_failed_and_v4_hostname_resolution_is_success
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]

    server_thread = Thread.new { server.accept }
    socket = TCPSocket.new(
      "localhost",
      port,
      fast_fallback: true,
      test_mode_settings: { delay: { ipv4: 10 }, error: { ipv6: Socket::EAI_FAIL } }
    )
    assert_true(socket.remote_address.ipv4?)
  ensure
    server_thread&.value&.close
    server&.close
    socket&.close
  end

  def test_initialize_resolv_timeout_with_connection_failure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      return
    end

    port = server.connect_address.ip_port
    server.close

    assert_raise(Errno::ETIMEDOUT) do
      TCPSocket.new(
        "localhost",
        port,
        resolv_timeout: 0.01,
        fast_fallback: true,
        test_mode_settings: { delay: { ipv4: 1000 } }
      )
    end
  end

  def test_initialize_with_hostname_resolution_failure_after_connection_failure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      return
    end

    port = server.connect_address.ip_port
    server.close

    assert_raise(Socket::ResolutionError) do
      TCPSocket.new(
        "localhost",
        port,
        fast_fallback: true,
        test_mode_settings: { delay: { ipv4: 100 }, error: { ipv4: Socket::EAI_FAIL } }
      )
    end
  end

  def test_initialize_with_connection_failure_after_hostname_resolution_failure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server = TCPServer.new("127.0.0.1", 0)
    port = server.connect_address.ip_port
    server.close

    assert_raise(Errno::ECONNREFUSED) do
      TCPSocket.new(
        "localhost",
        port,
        fast_fallback: true,
        test_mode_settings: { delay: { ipv4: 100 }, error: { ipv6: Socket::EAI_FAIL } }
      )
    end
  end

  def test_initialize_v6_connected_socket_with_v6_address
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      return
    end

    server_thread = Thread.new { server.accept }
    port = server.addr[1]

    socket = TCPSocket.new("::1", port)
    assert_true(socket.remote_address.ipv6?)
  ensure
    server_thread&.value&.close
    server&.close
    socket&.close
  end

  def test_initialize_v4_connected_socket_with_v4_address
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server = TCPServer.new("127.0.0.1", 0)
    server_thread = Thread.new { server.accept }
    port = server.addr[1]

    socket = TCPSocket.new("127.0.0.1", port)
    assert_true(socket.remote_address.ipv4?)
  ensure
    server_thread&.value&.close
    server&.close
    socket&.close
  end

  def test_initialize_fast_fallback_is_false
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server = TCPServer.new("127.0.0.1", 0)
    _, port, = server.addr
    server_thread = Thread.new { server.accept }

    socket = TCPSocket.new("127.0.0.1", port, fast_fallback: false)
    assert_true(socket.remote_address.ipv4?)
  ensure
    server_thread&.value&.close
    server&.close
    socket&.close
  end
end if defined?(TCPSocket)
```

#### 既存のテスト
- `TestSocket_TCPSocket#test_inspect` -> OK
- `TestSocket_TCPSocket#test_initialize_failure` -> OK
- `TestSocket_TCPSocket#test_initialize_resolv_timeout` -> OK (これは何をテストしているんだろう?)
- `TestSocket_TCPSocket#test_initialize_connect_timeout` -> OK
- `TestSocket_TCPSocket#test_recvfrom` -> OK
- `TestSocket_TCPSocket#test_encoding` -> OK
- `TestSocket_TCPSocket#test_accept_nonblock` -> OK
- `TestSocket_TCPSocket#test_accept_multithread` -> OK
- `TestSocket_TCPSocket#test_ai_addrconfig` -> OK

#### そのほか
自動テストでは検証が難しいが動作確認が必要なもの

- 複数の接続試行を開始後、ひとつが接続に成功した場合そのほかのfdがcloseされていること: OK
- `local_port` / `local_host`を指定して意図通りに動作すること: OK
- 連続して複数回実行できること: OK
