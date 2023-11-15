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
      if family == :PF_INET
        sleep 10
        [Addrinfo.tcp("127.0.0.1", port)]
      else
        [Addrinfo.tcp("::1", port)]
      end
    end

    server_thread = Thread.new { server.accept }
    connected_socket = Socket.tcp("localhost", port)
    server_thread.join

    assert_equal(
      connected_socket.remote_address.ipv6?,
      true
    )
  end

  def test_that_returns_IPv4_connected_socket_when_IPv6_address_name_resolution_takes_time
    server = TCPServer.new("127.0.0.1", 0)

    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == :PF_INET6
        sleep 10
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
  end

  def test_that_returns_IPv6_connected_socket_when_IPv6_address_name_resolved_in_resolution_delay
    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == :PF_INET6
        sleep 0.025
        [Addrinfo.tcp("::1", port)]
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    server_thread = Thread.new { server.accept }
    connected_socket = Socket.tcp("localhost", port)
    server_thread.join

    assert_equal(
      connected_socket.remote_address.ipv6?,
      true
    )
  end

  def test_that_returns_IPv4_connected_socket_when_IPv6_address_name_resolution_takes_time_and_IPv6_address_connecting_takes_more_time
    begin
      ipv6_server = Socket.new(:PF_INET6, :STREAM)
      ipv6_sockaddr = Socket.pack_sockaddr_in(0, "::1")
      ipv6_server.bind(ipv6_sockaddr)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    port = ipv6_server.connect_address.ip_port
    ipv4_server = Socket.new(:PF_INET, :STREAM)
    ipv4_sockaddr = Socket.pack_sockaddr_in(port, "127.0.0.1")
    ipv4_server.bind(ipv4_sockaddr)

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == :PF_INET6
        sleep 0.025
        [Addrinfo.tcp("::1", port)]
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    ipv6_server_thread = Thread.new { sleep 1; ipv6_server.listen(1) }
    ipv4_server_thread = Thread.new { ipv4_server.listen(1); ipv4_server.accept }
    connected_socket = Socket.tcp("localhost", port)
    ipv4_server_thread.join

    assert_equal(
      connected_socket.remote_address.ipv4?,
      true
    )

    ipv6_server.close
    ipv6_server_thread.kill
  end

  def test_that_returns_IPv6_connected_socket_when_IPv4_hostname_resolution_raises_SockerError
    begin
      server = TCPServer.new("::1", 0)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == :PF_INET6
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
  end

  def test_that_raises_ETIMEDOUT_with_resolv_timeout
    Addrinfo.define_singleton_method(:getaddrinfo) {|*arg| sleep }

    assert_raises(Errno::ETIMEDOUT) do
      Socket.tcp("localhost", 9, resolv_timeout: 0.1)
    end
  end

  def test_that_raises_ETIMEDOUT_with_connection_timeout
    begin
      ipv6_server = Socket.new(:PF_INET6, :STREAM)
      ipv6_sockaddr = Socket.pack_sockaddr_in(0, "::1")
      ipv6_server.bind(ipv6_sockaddr)
    rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
      exit
    end

    port = ipv6_server.connect_address.ip_port
    ipv4_server = Socket.new(:PF_INET, :STREAM)
    ipv4_sockaddr = Socket.pack_sockaddr_in(port, "127.0.0.1")
    ipv4_server.bind(ipv4_sockaddr)

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == :PF_INET6
        [Addrinfo.tcp("::1", port)]
      else
        [Addrinfo.tcp("127.0.0.1", port)]
      end
    end

    ipv6_server_thread = Thread.new { sleep(1); ipv6_server.listen(1); }
    ipv4_server_thread = Thread.new { sleep(1); ipv4_server.listen(1); }

    assert_raises(Errno::ETIMEDOUT) do
      Socket.tcp("localhost", port, connect_timeout: 0.1)
    end

    ipv4_server.close
    ipv4_server_thread.kill
    ipv6_server.close
    ipv6_server_thread.kill
  end

  def test_that_raises_ECONNREFUSED_with_connection_failure
    server = TCPServer.new("127.0.0.1", 0)
    _, port, = server.addr

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
      if family == :PF_INET6
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
