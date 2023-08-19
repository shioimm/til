# frozen_string_literal: true

require "minitest/autorun"
require "socket"

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

    Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, _, _, _, _|
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

  def test_that_raises_ETIMEDOUT_with_resolv_timeout
    Addrinfo.define_singleton_method(:getaddrinfo) {|*arg| sleep }

    sock = nil

    assert_raise(Errno::ETIMEDOUT) do
      sock = Socket.tcp("localhost", 9, resolv_timeout: 0.1)
    end
  end
end
