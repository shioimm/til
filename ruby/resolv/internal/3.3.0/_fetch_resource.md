# `DNS#fetch_resource`

```ruby
def fetch_resource(name, typeclass)
  lazy_initialize
  truncated = {}
  requesters = {}

  udp_requester = begin
    make_udp_requester
  rescue Errno::EACCES
    # fall back to TCP
  end

  senders = {}

  begin
    @config.resolv(name) do |candidate, tout, nameserver, port|
      msg = Message.new
      msg.rd = 1
      msg.add_question(candidate, typeclass)

      requester = requesters.fetch([nameserver, port]) do
        if !truncated[candidate] && udp_requester
          udp_requester
        else
          requesters[[nameserver, port]] = make_tcp_requester(nameserver, port)
        end
      end

      unless sender = senders[[candidate, requester, nameserver, port]]
        sender = requester.sender(msg, candidate, nameserver, port)
        next if !sender
        senders[[candidate, requester, nameserver, port]] = sender
      end

      reply, reply_name = requester.request(sender, tout)

      case reply.rcode
      when RCode::NoError
        if reply.tc == 1 and not Requester::TCP === requester
          # Retry via TCP:
          truncated[candidate] = true
          redo
        else
          yield(reply, reply_name)
        end
        return
      when RCode::NXDomain
        raise Config::NXDomain.new(reply_name.to_s)
      else
        raise Config::OtherResolvError.new(reply_name.to_s)
      end
    end
  ensure
    udp_requester&.close
    requesters.each_value { |requester| requester&.close }
  end
end
```

```ruby
def make_tcp_requester(host, port) # :nodoc:
  return Requester::TCP.new(host, port)
  # ...
end
```

```ruby
class TCP < Requester # :nodoc:
  def initialize(host, port=Port)
    super()
    @host = host
    @port = port
    sock = TCPSocket.new(@host, @port)
    @socks = [sock]
    @senders = {}
  end

  # #recv_reply
  # #sender
end
```
