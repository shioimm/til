# frozen_string_literal: true

require "minitest/autorun"
require_relative "./socket"

class SocketTest < Minitest::Test
  def test_that_returns_IPv6_connected_socket_when_IPv4_address_name_resolution_takes_time
    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        [Addrinfo.tcp("::1", port)]
      else
        sleep 1
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    server_thread = Thread.new { server.accept }
    connected_socket = Socket.tcp("localhost", port)

    assert_equal(
      connected_socket.remote_address.ipv6?,
      true
    )
  ensure
    server_thread.value.close
    server.close
    connected_socket.close if connected_socket && !connected_socket.closed?
  end

  def test_that_returns_IPv4_connected_socket_when_IPv6_address_name_resolution_takes_time
    server = TCPServer.new("127.0.0.1", 0)
    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        sleep 1
        [Addrinfo.tcp("::1", port)]
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    server_thread = Thread.new { server.accept }
    connected_socket = Socket.tcp("localhost", port)
    server_thread.join

    assert_equal(
      connected_socket.remote_address.ipv4?,
      true
    )
  ensure
    server_thread.value.close
    server.close
    connected_socket.close if connected_socket && !connected_socket.closed?
  end

  def test_that_returns_IPv6_connected_socket_when_IPv6_address_name_resolved_in_resolution_delay
    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        sleep 0.025
        [Addrinfo.tcp("::1", port)]
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    server_thread = Thread.new { server.accept }
    connected_socket = Socket.tcp("localhost", port)

    assert_equal(
      connected_socket.remote_address.ipv6?,
      true
    )
  ensure
    server_thread.value.close
    server.close
    connected_socket.close if connected_socket && !connected_socket.closed?
  end

  def test_that_returns_IPv4_connected_socket_when_IPv6_address_name_resolution_takes_time_and_IPv6_address_connecting_takes_more_time
    begin
      ipv6_server = Socket.new(Socket::AF_INET6, :STREAM)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    ipv6_server.bind(Socket.pack_sockaddr_in(0, "::1"))
    port = ipv6_server.connect_address.ip_port
    ipv4_server = Socket.new(Socket::AF_INET, :STREAM)
    ipv4_server.bind(Socket.pack_sockaddr_in(port, "127.0.0.1"))

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        sleep 0.025
        [Addrinfo.tcp("::1", port)]
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    ipv4_server_thread = Thread.new { ipv4_server.listen(1); ipv4_server.accept }
    connected_socket = Socket.tcp("localhost", port)

    assert_equal(
      connected_socket.remote_address.ipv4?,
      true
    )
  ensure
    ipv6_server.close
    accepted, _ = ipv4_server_thread.value
    accepted.close
    ipv4_server.close
    connected_socket.close if connected_socket && !connected_socket.closed?
  end

  def test_that_returns_IPv6_connected_socket_when_IPv4_hostname_resolution_raises_SockerError
    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        sleep 0.1
        [Addrinfo.tcp("::1", port)]
      else
        raise SocketError
      end
    end

    server_thread = Thread.new { server.accept }
    connected_socket = Socket.tcp("localhost", port)
    server_thread.join

    assert_equal(
      connected_socket.remote_address.ipv6?,
      true
    )
  ensure
    server.close
    server_thread.value.close
    connected_socket.close if connected_socket && !connected_socket.closed?
  end

  def test_that_returns_IPv4_connected_socket_when_IPv6_hostname_resolution_raises_SockerError
    server = TCPServer.new("127.0.0.1", 0)
    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        raise SocketError
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    server_thread = Thread.new { server.accept }
    connected_socket = Socket.tcp("localhost", port)
    server_thread.join

    assert_equal(
      connected_socket.remote_address.ipv4?,
      true
    )
  ensure
    server.close
    server_thread.value.close
    connected_socket.close if connected_socket && !connected_socket.closed?
  end

  def test_that_ignore_error_with_IPv4_hostname_resolution_after_successful_IPv6_hostname_resolution
    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        [Addrinfo.tcp("::1", port)]
      else
        sleep 0.01
        raise SocketError
      end
    end

    server_thread = Thread.new { sleep(0.05); server.accept }
    connected_socket = Socket.tcp("localhost", port)
    server_thread.join

    assert_equal(
      connected_socket.remote_address.ipv6?,
      true
    )
  ensure
    server.close
    server_thread.value.close
    connected_socket.close if connected_socket && !connected_socket.closed?
  end

  def test_that_raises_last_error_with_failing_all_hostname_resolutions
    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        sleep 0.1
        raise RuntimeError, "Last hostname resolution error"
      else
        raise RuntimeError
      end
    end

    e = assert_raises(RuntimeError) do
      Socket.tcp("localhost", 9)
    end

    assert_equal(e.message, "Last hostname resolution error")
  end

  def test_that_raises_ETIMEDOUT_with_resolv_timeout
    Addrinfo.define_singleton_method(:getaddrinfo) { |*_| sleep }

    assert_raises(Errno::ETIMEDOUT) do
      Socket.tcp("localhost", 9, resolv_timeout: 0.1)
    end
  end

  def test_that_raises_ETIMEDOUT_with_connection_timeout
    server = Socket.new(Socket::AF_INET, :STREAM)
    sockaddr = Socket.pack_sockaddr_in(0, "127.0.0.1")
    server.bind(sockaddr)
    port = server.connect_address.ip_port

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        [Addrinfo.tcp("::1", port)]
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    assert_raises(Errno::ETIMEDOUT) do
      Socket.tcp("localhost", port, connect_timeout: 0.0001)
    end

    server.close
  end

  def test_that_raises_ECONNREFUSED_with_connection_failure
    server = TCPServer.new("127.0.0.1", 12345)
    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == Socket::AF_INET6
        [Addrinfo.tcp("::1", port)]
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    server.close

    assert_raises(Errno::ECONNREFUSED) do
      Socket.tcp("localhost", port)
    end
  end
end
