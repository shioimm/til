# frozen_string_literal: true
class TestSocket_TCPSocket < Test::Unit::TestCase
# ...

  # 先にIPv6の名前解決が完了
  def test_initialize_v6_hostname_resolved_earlier
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      begin
        server = TCPServer.new("::1", 0)
      rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
        exit
      end

      server_thread = Thread.new { server.accept }
      port = server.addr[1]

      socket = TCPSocket.new("localhost", port, test_mode_settings: { delay: { ipv4: 1000 } })
      assert_true(socket.remote_address.ipv6?)
      server_thread.value.close
      server.close
      socket.close if socket && !socket.closed?
    end;
  end

  # 先にIPv4の名前解決が完了
  def test_initialize_v4_hostname_resolved_earlier
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      server_thread = Thread.new { server.accept }
      socket = TCPSocket.new("localhost", port, test_mode_settings: { delay: { ipv6: 1000 } })

      assert_true(socket.remote_address.ipv4?)
      server_thread.value.close
      server.close
      socket.close if socket && !socket.closed?
    end;
  end

  # 先にIPv4の名前解決が完了し、Resolution Delay中にIPv6の名前解決が完了したためIPv6での接続に成功
  def test_initialize_v6_hostname_resolved_in_resolution_delay
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      begin
        server = TCPServer.new("::1", 0)
      rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
        exit
      end

      port = server.addr[1]
      delay_time = 25 # Socket::RESOLUTION_DELAY (private) is 50ms

      server_thread = Thread.new { server.accept }
      socket = TCPSocket.new("localhost", port, test_mode_settings: { delay: { ipv6: delay_time } })
      assert_true(socket.remote_address.ipv6?)
      server_thread.value.close
      server.close
      socket.close if socket && !socket.closed?
    end;
  end

  # 先にIPv6の名前解決が完了したが接続に失敗。IPv4での接続に成功
  def test_initialize_v6_hostname_resolved_earlier_and_v6_server_is_not_listening
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      ipv4_address = "127.0.0.1"
      ipv4_server = Socket.new(Socket::AF_INET, :STREAM)
      ipv4_server.bind(Socket.pack_sockaddr_in(0, ipv4_address))
      port = ipv4_server.connect_address.ip_port

      ipv4_server_thread = Thread.new { ipv4_server.listen(1); ipv4_server.accept }
      socket = TCPSocket.new("localhost", port, test_mode_settings: { delay: { ipv4: 10 } })
      assert_equal(ipv4_address, socket.remote_address.ip_address)

      accepted, _ = ipv4_server_thread.value
      accepted.close
      ipv4_server.close
      socket.close if socket && !socket.closed?
    end;
  end

  # 先にIPv6の名前解決が完了したが接続に失敗。名前解決タイムアウトのためErrno::ETIMEDOUT
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

  # 要検討
  # - IPv6名前解決中に例外発生
  # - 接続タイムアウトのためErrno::ETIMEDOUT

  # fast_fallbackオプション: false
  def test_initialize_fast_fallback_is_false
    server = TCPServer.new("127.0.0.1", 0)
    _, port, = server.addr
    server_thread = Thread.new { server.accept }
    socket = TCPSocket.new("127.0.0.1", port, fast_fallback: false)

    assert_true(socket.remote_address.ipv4?)
    server_thread.value.close
    server.close
    socket.close if socket && !socket.closed?
  end
end if defined?(TCPSocket)
