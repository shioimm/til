# frozen_string_literal: true

require "test/unit"
require_relative "./socket"

class SocketTest < Test::Unit::TestCase
  def test_tcp_socket_v6_hostname_resolved_earlier
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      exit if Socket.ip_address_list.none? do |ai|
        ai.ipv6? && (!ai.ipv6_loopback? && !ai.ipv6_multicast? && !ai.ipv6_linklocal?)
      end

      begin
        server = TCPServer.new("::1", 0)
      rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
        exit
      end

      server_thread = Thread.new { server.accept }
      port = server.addr[1]

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then sleep(10); [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      socket = Socket.tcp("localhost", port)
      assert_true(socket.remote_address.ipv6?)
      server_thread.value.close
      server.close
      socket.close if socket && !socket.closed?
    end;
  end

  def test_tcp_socket_v4_hostname_resolved_earlier
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then sleep(10); [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      server_thread = Thread.new { server.accept }
      socket = Socket.tcp("localhost", port)
      assert_true(socket.remote_address.ipv4?)
      server_thread.value.close
      server.close
      socket.close if socket && !socket.closed?
    end;
  end

  def test_tcp_socket_v6_hostname_resolved_in_resolution_delay
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      exit if Socket.ip_address_list.none? do |ai|
        ai.ipv6? && (!ai.ipv6_loopback? && !ai.ipv6_multicast? && !ai.ipv6_linklocal?)
      end

      begin
        server = TCPServer.new("::1", 0)
      rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
        exit
      end

      port = server.addr[1]
      delay_time = 0.025 # Socket::RESOLUTION_DELAY (private) is 0.05

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then sleep(delay_time); [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      server_thread = Thread.new { server.accept }
      socket = Socket.tcp("localhost", port)
      assert_true(socket.remote_address.ipv6?)
      server_thread.value.close
      server.close
      socket.close if socket && !socket.closed?
    end;
  end

  def test_tcp_socket_v6_hostname_resolved_earlier_and_v6_server_is_not_listening
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      ipv4_address = "127.0.0.1"
      ipv4_server = Socket.new(Socket::AF_INET, :STREAM)
      ipv4_server.bind(Socket.pack_sockaddr_in(0, ipv4_address))
      port = ipv4_server.connect_address.ip_port

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then sleep(0.001); [Addrinfo.tcp(ipv4_address, port)]
        end
      end

      ipv4_server_thread = Thread.new { ipv4_server.listen(1); ipv4_server.accept }
      socket = Socket.tcp("localhost", port)
      assert_equal(ipv4_address, socket.remote_address.ip_address)

      accepted, _ = ipv4_server_thread.value
      accepted.close
      ipv4_server.close
      socket.close if socket && !socket.closed?
    end;
  end

  def test_tcp_socket_resolv_timeout
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      Addrinfo.define_singleton_method(:getaddrinfo) { |*_|
        if Socket.ip_address_list.none? { |ai|
          ai.ipv6? && (!ai.ipv6_loopback? && !ai.ipv6_multicast? && !ai.ipv6_linklocal?)
        }
          raise Errno::ETIMEDOUT
        else
          sleep
        end
      }

      port = TCPServer.new("127.0.0.1", 0).addr[1]

      assert_raise(Errno::ETIMEDOUT) do
        Socket.tcp("localhost", port, resolv_timeout: 0.01)
      end
    end;
  end

  def test_tcp_socket_one_hostname_resolution_succeeded_at_least
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      server = TCPServer.new("127.0.0.1", 0)
      port = server.addr[1]

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then sleep(0.01); raise SocketError
        when Socket::AF_INET then [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      server_thread = Thread.new { server.accept }
      socket = nil

      assert_nothing_raised do
        socket = Socket.tcp("localhost", port)
      end

      server_thread.value.close
      server.close
      socket.close if socket && !socket.closed?
    end;
  end

  def test_tcp_socket_all_hostname_resolution_failed
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then raise SocketError
        when Socket::AF_INET then sleep(0.001); raise SocketError, "Last hostname resolution error"
        end
      end
      port = TCPServer.new("localhost", 0).addr[1]

      assert_raise_with_message(SocketError, "Last hostname resolution error") do
        Socket.tcp("localhost", port)
      end
    end;
  end

  def test_tcp_socket_v6_address_passed
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      begin
        server = TCPServer.new("::1", 0)
      rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
        exit
      end

      _, port, = server.addr

      Addrinfo.define_singleton_method(:getaddrinfo) do |*_|
        [Addrinfo.tcp("::1", port)]
      end

      server_thread = Thread.new { server.accept }
      socket = Socket.tcp("::1", port)

      assert_true(socket.remote_address.ipv6?)
      server_thread.value.close
      server.close
      socket.close if socket && !socket.closed?
    end;
  end

  def test_tcp_socket_fast_fallback_is_false
    server = TCPServer.new("127.0.0.1", 0)
    _, port, = server.addr
    server_thread = Thread.new { server.accept }
    socket = Socket.tcp("127.0.0.1", port, fast_fallback: false)

    assert_true(socket.remote_address.ipv4?)
    server_thread.value.close
    server.close
    socket.close if socket && !socket.closed?
  end
end
