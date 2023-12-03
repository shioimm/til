# frozen_string_literal: true

# Socket.tcpの動作を検証しているテスト項目
#   #test_accept_loop
#   #test_accept_loop_multi_port
#   #test_connect_timeout
#
# 追加するテスト項目
#   名前解決の検証
#     先にIPv6 addrinfoを取得した場合 -> assert_true(ipv6?)
#     先にIPv4 addrinfoを取得した場合 -> assert_true(ipv4?)
#     先にIPv4 addrinfoを取得したが、Resolution Delay中にIPv6 addrinfoを取得した場合 -> assert_true(ipv6?)
#  接続の検証
#     IPv6 addrinfo -> IPv4 addrinfoの順でconnectを開始し、先にIPv4 addrinfoで接続確立した場合 -> assert_true(ipv4?)
#  エラーの検証
#     名前解決中にresolv_timeoutがタイムアウトした場合 -> assert_raise(Errno::ETIMEDOUT)
#     Aレコードの取得に失敗した後AAAAレコードの取得に成功した場合 -> assert_nothing_raised
#     名前解決がSocketErrorで失敗した場合 -> assert_raise_with_message(SocketError, ...) (最後のmessageを取得)

require "test/unit"
require_relative "./socket"

class SocketTest < Test::Unit::TestCase
  def test_tcp_socket_v6_hostname_resolved_faster
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

  def test_tcp_socket_v4_hostname_resolved_faster
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

  def test_tcp_socket_v6_hostname_resolved_faster_and_v4_received_ack_faster
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
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
        case family
        when Socket::AF_INET6 then [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then sleep(0.01); [Addrinfo.tcp("127.0.0.1", port)]
        end
      end

      ipv4_server_thread = Thread.new { ipv4_server.listen(1); ipv4_server.accept }
      socket = Socket.tcp("localhost", port)
      assert_true(socket.remote_address.ipv4?)

      ipv6_server.close
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
      Addrinfo.define_singleton_method(:getaddrinfo) { |*_| sleep }
      port = TCPServer.new("localhost", 0).addr[1]

      assert_raise(Errno::ETIMEDOUT) do
        Socket.tcp("localhost", port, resolv_timeout: 0.01)
      end
    end;
  end

  def test_tcp_socket_one_hostname_resolution_succeeded_at_least
    opts = %w[-rsocket -W1]
    assert_separately opts, "#{<<-"begin;"}\n#{<<-'end;'}"

    begin;
      begin
        server = TCPServer.new("::1", 0)
      rescue Errno::EADDRNOTAVAIL # IPv6 is not supported
        exit
      end

      port = server.addr[1]

      Addrinfo.define_singleton_method(:getaddrinfo) do |_, _, family, *_|
        case family
        when Socket::AF_INET6 then [Addrinfo.tcp("::1", port)]
        when Socket::AF_INET then sleep(0.01); raise SocketError
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
        when Socket::AF_INET then sleep(0.01); raise SocketError, "Last hostname resolution error"
        end
      end
      port = TCPServer.new("localhost", 0).addr[1]

      assert_raise_with_message(SocketError, "Last hostname resolution error") do
        Socket.tcp("localhost", port)
      end
    end;
  end
end
