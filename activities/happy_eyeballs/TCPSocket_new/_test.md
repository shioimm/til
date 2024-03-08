# `test/socket/test_tcp.rb`

```ruby
class TestSocket_TCPSocket < Test::Unit::TestCase
  # ...

  def test_tcp_socket_v6_hostname_resolved_earlier
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

      socket = TCPSocket.new("localhost", port)
      assert_true(socket.remote_address.ipv6?)
      server_thread.value.close
      server.close
      socket.close if socket && !socket.closed?
    end;
  end
end if defined?(TCPSocket)
```
