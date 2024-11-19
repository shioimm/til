# frozen_string_literal: true
class TestSocket_TCPSocket < Test::Unit::TestCase
# ...

  # 先にIPv6の名前解決が完了
  def test_initialize_v6_hostname_resolved_earlier
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
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
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server_thread.value.close
    server.close
    socket.close if socket && !socket.closed?
  end

  # 先にIPv4の名前解決が完了
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
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server_thread.value.close
    server.close
    socket.close if socket && !socket.closed?
  end

  # 先にIPv4の名前解決が完了し、Resolution Delay中にIPv6の名前解決が完了したためIPv6での接続に成功
  def test_initialize_v6_hostname_resolved_in_resolution_delay
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
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
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server_thread.value.close
    server.close
    socket.close if socket && !socket.closed?
  end

  # 先にIPv6の名前解決が完了したが接続に失敗。IPv4での接続に成功
  def test_initialize_v6_hostname_resolved_earlier_and_v6_server_is_not_listening
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    ipv4_address = "127.0.0.1"
    ipv4_server = Socket.new(Socket::AF_INET, :STREAM)
    ipv4_server.bind(Socket.pack_sockaddr_in(0, ipv4_address))
    port = ipv4_server.connect_address.ip_port

    ipv4_server_thread = Thread.new { ipv4_server.listen(1); ipv4_server.accept }
    socket = TCPSocket.new(
      "localhost",
      port,
      fast_fallback: true,
      test_mode_settings: { delay: { ipv4: 10 } }
    )
    assert_equal(ipv4_address, socket.remote_address.ip_address)
  ensure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    accepted, _ = ipv4_server_thread.value
    accepted.close
    ipv4_server.close
    socket.close if socket && !socket.closed?
  end

  # 先にIPv4の名前解決が完了し、後からIPv6の名前解決が完了。
  # Resolution DelayのためIPv6宛に接続を開始したがIPv6サーバが起動していないため接続に失敗し、IPv4で接続確立
  def test_initialize_v6_hostname_resolved_later_and_v6_server_is_not_listening
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    ipv4_server = Socket.new(Socket::AF_INET, :STREAM)
    ipv4_server.bind(Socket.pack_sockaddr_in(0, "127.0.0.1"))
    port = ipv4_server.connect_address.ip_port

    ipv4_server_thread = Thread.new { ipv4_server.listen(1); ipv4_server.accept }
    socket = TCPSocket.new(
      "localhost",
      port,
      fast_fallback: true,
      test_mode_settings: { delay: { ipv6: 25 } }
    )

    assert_equal(
      socket.remote_address.ipv4?,
      true
    )
  ensure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    accepted, _ = ipv4_server_thread.value
    accepted.close
    ipv4_server.close
    socket.close if socket && !socket.closed?
  end

  # IPv6の名前解決に失敗し、その後IPv4の名前解決に成功
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
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server_thread.value.close
    server.close
    socket.close if socket && !socket.closed?
  end

  # 先にIPv6の名前解決が完了したが接続に失敗。IPv4名前解決タイムアウトのためErrno::ETIMEDOUT
  def test_initialize_resolv_timeout_with_connection_failure
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"
    server = TCPServer.new("::1", 0)
    port = server.connect_address.ip_port
    server.close

    begin;
      assert_raise(Errno::ETIMEDOUT) do
        TCPSocket.new("localhost", port, resolv_timeout: 0.01, test_mode_settings: { delay: { ipv4: 1000 } })
      end
    end;
  end

  # IPv6の接続失敗後にIPv4の名前解決失敗のためSocket::ResolutionError
  def test_initialize_with_hostname_resolution_failure_after_connection_failure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    assert_raise(Socket::ResolutionError) do
      TCPSocket.new(
        "localhost",
        0,
        fast_fallback: true,
        test_mode_settings: { delay: { ipv4: 100 }, error: { ipv4: Socket::EAI_FAIL } }
      )
    end
  end

  # IPv6の名前解決失敗後にIPv4の接続失敗のためErrno::ECONNREFUSED
  def test_initialize_with_connection_failure_after_hostname_resolution_failure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    assert_raise(Errno::ECONNREFUSED) do
      TCPSocket.new(
        "localhost",
        0,
        fast_fallback: true,
        test_mode_settings: { delay: { ipv4: 100 }, error: { ipv6: Socket::EAI_FAIL } }
      )
    end
  end

  # IPv6アドレスを直接指定
  def test_initialize_v6_connected_socket_with_v6_address
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    server_thread = Thread.new { server.accept }
    port = server.addr[1]

    socket = TCPSocket.new("::1", port)
    assert_true(socket.remote_address.ipv6?)
  ensure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server_thread.value.close
    server.close
    socket.close if socket && !socket.closed?
  end

  # IPv4アドレスを直接指定
  def test_initialize_v4_connected_socket_with_v4_address
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server = TCPServer.new("127.0.0.1", 0)
    server_thread = Thread.new { server.accept }
    port = server.addr[1]

    socket = TCPSocket.new("127.0.0.1", port)
    assert_true(socket.remote_address.ipv4?)
  ensure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server_thread.value.close
    server.close
    socket.close if socket && !socket.closed?
  end

  # fast_fallbackオプション: false
  def test_initialize_fast_fallback_is_false
    server = TCPServer.new("127.0.0.1", 0)
    _, port, = server.addr
    server_thread = Thread.new { server.accept }

    socket = TCPSocket.new("127.0.0.1", port, fast_fallback: false)
    assert_true(socket.remote_address.ipv4?)
  ensure
    return if RUBY_PLATFORM =~ /mswin|mingw|cygwin/

    server_thread.value.close
    server.close
    socket.close if socket && !socket.closed?
  end
end if defined?(TCPSocket)
