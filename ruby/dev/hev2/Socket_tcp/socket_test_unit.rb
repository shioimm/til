# frozen_string_literal: true

require "test/unit"
require_relative "./socket"

class SocketTest < Test::Unit::TestCase
  def test_tcp_socket_v6_hostname_resolved_earlier
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    begin
      begin
        # Verify that "localhost" can be resolved to an IPv6 address
        Socket.getaddrinfo("localhost", 0, Socket::AF_INET6)
        server = TCPServer.new("::1", 0)
      rescue Socket::ResolutionError, Errno::EADDRNOTAVAIL # IPv6 is not supported
        return
      end

      _, port, = server.addr
      server_thread = Thread.new { server.accept }

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then sleep(10); [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      socket = Socket.tcp("localhost", port)
      assert_true(socket.remote_address.ipv6?)
    ensure
      server_thread&.value&.close
      server&.close
      socket&.close
    end
    RUBY
  end

  def test_tcp_socket_v4_hostname_resolved_earlier
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    begin
      server = TCPServer.new("127.0.0.1", 0)
      _, port, = server.addr
      server_thread = Thread.new { server.accept }

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then sleep(10); [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      socket = Socket.tcp("localhost", port)
      assert_true(socket.remote_address.ipv4?)
    ensure
      server_thread&.value&.close
      server&.close
      socket&.close
    end
    RUBY
  end

  def test_tcp_socket_v6_hostname_resolved_in_resolution_delay
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    begin
      begin
        # Verify that "localhost" can be resolved to an IPv6 address
        Socket.getaddrinfo("localhost", 0, Socket::AF_INET6)
        server = TCPServer.new("::1", 0)
      rescue Socket::ResolutionError, Errno::EADDRNOTAVAIL # IPv6 is not supported
        return
      end

      _, port, = server.addr
      server_thread = Thread.new { server.accept }

      delay_time = 0.025 # Socket::RESOLUTION_DELAY (private) is 0.05

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then sleep(delay_time); [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      socket = Socket.tcp("localhost", port)
      assert_true(socket.remote_address.ipv6?)
    ensure
      server_thread&.value&.close
      server&.close
      socket&.close
    end
    RUBY
  end

  def test_tcp_socket_v6_hostname_resolved_earlier_and_v6_server_is_not_listening
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    begin
      ipv4_address = "127.0.0.1"
      server = Socket.new(Socket::AF_INET, :STREAM)
      server.bind(Socket.pack_sockaddr_in(0, ipv4_address))
      port = server.connect_address.ip_port
      server_thread = Thread.new { server.listen(1); server.accept }

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then sleep(0.001); [Addrinfo.tcp(ipv4_address, port)]
        end
      end

      socket = Socket.tcp("localhost", port)
      assert_equal(ipv4_address, socket.remote_address.ip_address)
    ensure
      accepted, _ = server_thread&.value
      accepted&.close
      server&.close
      socket&.close
    end
    RUBY
  end

  def test_tcp_socket_resolv_timeout
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    begin
      server = TCPServer.new("localhost", 0)
      _, port, = server.addr

      Addrinfo.define_singleton_method(:getaddrinfo) { |*_| sleep }

      assert_raise(Errno::ETIMEDOUT) do
        Socket.tcp("localhost", port, resolv_timeout: 0.01)
      end
    ensure
      server&.close
    end
    RUBY
  end

  def test_tcp_socket_resolv_timeout_with_connection_failure
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    server = TCPServer.new("127.0.0.1", 12345)
    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        sleep
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    server.close

    assert_raise(Errno::ETIMEDOUT) do
      Socket.tcp("localhost", port, resolv_timeout: 0.01)
    end
    RUBY
  end

  def test_tcp_socket_one_hostname_resolution_succeeded_at_least
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    begin
      begin
        # Verify that "localhost" can be resolved to an IPv6 address
        Socket.getaddrinfo("localhost", 0, Socket::AF_INET6)
        server = TCPServer.new("::1", 0)
      rescue Socket::ResolutionError, Errno::EADDRNOTAVAIL # IPv6 is not supported
        return
      end

      _, port, = server.addr
      server_thread = Thread.new { server.accept }

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then sleep(0.001); raise SocketError
        end
      end

      socket = nil

      assert_nothing_raised do
        socket = Socket.tcp("localhost", port)
      end
    ensure
      server_thread&.value&.close
      server&.close
      socket&.close
    end
    RUBY
  end

  def test_tcp_socket_all_hostname_resolution_failed
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    begin
      server = TCPServer.new("localhost", 0)
      _, port, = server.addr

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then raise SocketError
        when Socket::AF_INET then sleep(0.001); raise SocketError, "Last hostname resolution error"
        end
      end

      assert_raise_with_message(SocketError, "Last hostname resolution error") do
        Socket.tcp("localhost", port)
      end
    ensure
      server&.close
    end
    RUBY
  end

  def test_tcp_socket_v6_address_passed
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    begin
      begin
        # Verify that "localhost" can be resolved to an IPv6 address
        Socket.getaddrinfo("localhost", 0, Socket::AF_INET6)
        server = TCPServer.new("::1", 0)
      rescue Socket::ResolutionError, Errno::EADDRNOTAVAIL # IPv6 is not supported
        return
      end

      _, port, = server.addr
      server_thread = Thread.new { server.accept }

      Addrinfo.define_singleton_method(:getaddrinfo) do |*_|
        [Addrinfo.tcp("::1", port)]
      end

      socket = Socket.tcp("::1", port)
      assert_true(socket.remote_address.ipv6?)
    ensure
      server_thread&.value&.close
      server&.close
      socket&.close
    end
    RUBY
  end

  def test_tcp_socket_fast_fallback_is_false
    server = TCPServer.new("127.0.0.1", 0)
    _, port, = server.addr
    server_thread = Thread.new { server.accept }
    socket = Socket.tcp("127.0.0.1", port, fast_fallback: false)
    assert_true(socket.remote_address.ipv4?)
  ensure
    server_thread&.value&.close
    server&.close
    socket&.close
  end

  def test_tcp_fast_fallback
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    assert_true(Socket.tcp_fast_fallback)

    Socket.tcp_fast_fallback = false
    assert_false(Socket.tcp_fast_fallback)

    Socket.tcp_fast_fallback = true
    assert_true(Socket.tcp_fast_fallback)
    RUBY
  end
end
