# `Resolv::DNS#getresources`

```ruby
require "resolv"
dns = Resolv::DNS.new
dns.getresources("cloudflare.com", Resolv::DNS::Resource::IN::HTTPS)

# [#<Resolv::DNS::Resource::IN::HTTPS:0x00000001257c9068
#   @params=
#    #<Resolv::DNS::SvcParams:0x0000000125088ec0
#     @params=
#      {1 =>
         #<Resolv::DNS::SvcParam::ALPN:0x00000001250892f8 @protocol_ids=["h3", "h2"]>,
#       4 =>
#        #<Resolv::DNS::SvcParam::IPv4Hint:0x00000001250890f0
#         @addresses=[#<Resolv::IPv4 ***.**.***.***>, #<Resolv::IPv4 ***.**.***.***>]>,
#       6 =>
#        #<Resolv::DNS::SvcParam::IPv6Hint:0x0000000125088f38
#         @addresses=[#<Resolv::IPv6 ****:****:****:****>, #<Resolv::IPv6 ****:****:****:****>]>}>,
#   @priority=1,
#   @target=#<Resolv::DNS::Name: .>,
#   @ttl=185>]

dns.method(:getresources).source_location
# "path/to/.rbenv/versions/3.4.5/lib/ruby/3.4.0/resolv.rb", 512
```

```ruby
class Resolv
  class DNS
    Port = 53

    def initialize(config_info=nil)
      @mutex = Thread::Mutex.new
      @config = Config.new(config_info)
      @initialized = nil
    end

    # name      = "example.com"
    # typeclass = Resolv::DNS::Resource::IN::HTTPS
    def getresources(name, typeclass)
      ret = []
      each_resource(name, typeclass) {|resource| ret << resource}
      return ret
    end

    # name      = "example.com"
    # typeclass = Resolv::DNS::Resource::IN::HTTPS
    # &proc     = {|resource| ret << resource}
    def each_resource(name, typeclass, &proc)
      fetch_resource(name, typeclass) {|reply, reply_name|
        extract_resources(reply, reply_name, typeclass, &proc)
      }
    end

    # name      = "example.com"
    # typeclass = Resolv::DNS::Resource::IN::HTTPS
    def fetch_resource(name, typeclass)
      lazy_initialize # ここで@config.lazy_initializeを呼ぶ

      truncated = {}
      requesters = {}

      # Requester::ConnectedUDPもしくはRequester::UnconnectedUDP
      udp_requester = begin
        make_udp_requester
      rescue Errno::EACCES
        # fall back to TCP
      end

      senders = {}

      begin
        @config.resolv(name) do |candidate, tout, nameserver, port|
          # candidate  = #<Resolv::DNS::Name: cloudflare.com.>
          # tout       = 5
          # nameserver = "****:***:****:*::*"
          # port       = 53

          msg = Message.new
          msg.rd = 1 # rd = recursion desired
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

          # (sender)
          # #<Resolv::DNS::Requester::UnconnectedUDP:0x00000001264a9620
          #   @senders={}, @socks=nil,
          #   @nameserver_port=[
          #     ["****:***:****:*::*", 53],
          #     ["****:***:****:*::*", 53],
          #     ["***.***.*.*", 53]
          #   ],
          #   @initialized=false, @mutex=#<Thread::Mutex:0x0000000125db8898>>

          # Requester#request
          reply, reply_name = requester.request(sender, tout)
          # (reply)
          # #<Resolv::DNS::Message:0x0000000120952a88
          #   @id=58045, @qr=1, @opcode=0, @aa=0, @tc=0, @rd=1, @ra=1, @rcode=0,
          #   @question=[[#<Resolv::DNS::Name: cloudflare.com.>, Resolv::DNS::Resource::IN::HTTPS]],
          #   @answer=[[
          #     <Resolv::DNS::Name: cloudflare.com.>,
          #     300,
          #     #<Resolv::DNS::Resource::IN::HTTPS:0x0000000121f78f88
          #       @priority=1,
          #       @target=#<Resolv::DNS::Name: .>,
          #       @params=#<Resolv::DNS::SvcParams:0x0000000121f78e98
          #                 @params={
          #                   1 => #<Resolv::DNS::SvcParam::ALPN:0x0000000121f79f78 @protocol_ids=["h3", "h2"]>,
          #                   4 => #<Resolv::DNS::SvcParam::IPv4Hint:0x0000000121f79848
          #                          @addresses=[#<Resolv::IPv4 ***.**.***.***>, #<Resolv::IPv4 ***.**.***.***>]>,
          #                   6 => #<Resolv::DNS::SvcParam::IPv6Hint:0x0000000121f793c0
          #                          @addresses=[#<Resolv::IPv6 ****:****::****:****>,#<Resolv::IPv6 ****:****::****:****>]>
          #                 }>,
          #                 @ttl=300>
          #   ]],
          #   @authority=[],
          #   @additional=[[
          #     #<Resolv::DNS::Name: cloudflare.com.>,
          #     71,
          #     #<Resolv::DNS::Resource::IN::A:0x0000000121f78790 @address=#<Resolv::IPv4 ***.**.***.***>,
          #      @ttl=71>
          #   ],[
          #     #<Resolv::DNS::Name: cloudflare.com.>,
          #     71,
          #     #<Resolv::DNS::Resource::IN::A:0x0000000121f77ea8 @address=#<Resolv::IPv4 ***.**.***.***>,
          #     @ttl=71>
          #   ],[
          #     #<Resolv::DNS::Name: cloudflare.com.>,
          #     114,
          #     #<Resolv::DNS::Resource::IN::AAAA:0x0000000121f77750 @address=#<Resolv::IPv6 ****:****::****:****>,
          #     @ttl=114>
          #   ],[
          #     #<Resolv::DNS::Name: cloudflare.com.>,
          #     114,
          #     #<Resolv::DNS::Resource::IN::AAAA:0x0000000121f770c0 @address=#<Resolv::IPv6 ****:****::****:****>,
          #     @ttl=114>
          #   ]]>

          # (reply_name)
          # #<Resolv::DNS::Name: cloudflare.com.>

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

    class Config
      def initialize(config_info=nil)
        @mutex = Thread::Mutex.new
        @config_info = config_info
        @initialized = nil
        @timeouts = nil
      end

      # DNS#fetch_resource実行時に呼ばれる
      def lazy_initialize
        @nameserver_port = []
        @use_ipv6 = nil
        @search = nil
        @ndots = 1

        case @config_info
        when nil
          config_hash = Config.default_config_hash
          # Config.default_config_hash(filename="/etc/resolv.conf")
          # => {nameserver: ["****:***:****:*::*", "****:***:****:*::*", "***.***.*.*", search: nil, ndots: 1}

          # ...
        end

        if config_hash.include? :nameserver
          # [["****:***:****:*::*", 53], ["****:***:****:*::*", 53], ["***.***.*.*", 53]] の組みを作る
          @nameserver_port = config_hash[:nameserver].map {|ns| [ns, Port] }
        end

        if config_hash.include? :nameserver_port
          @nameserver_port = config_hash[:nameserver_port].map {|ns, port| [ns, (port || Port)] }
        end

        if config_hash.include? :use_ipv6
          @use_ipv6 = config_hash[:use_ipv6]
        end

        @search = config_hash[:search] if config_hash.include? :search # nilが入ってそう
        @ndots = config_hash[:ndots] if config_hash.include? :ndots
        @raise_timeout_errors = config_hash[:raise_timeout_errors]

        if @nameserver_port.empty?
          @nameserver_port << ['0.0.0.0', Port]
        end

        if @search
          @search = @search.map {|arg| Label.split(arg) }
        else
          hostname = Socket.gethostname # システムの標準のホスト名を取得 "**********.local"
          if /\./ =~ hostname
            @search = [Label.split($')] # [[#<Str:0x0000000122791878 @downcase="local", @string="local">]]
          else
            @search = [[]]
          end
        end

        # ...バリデーションが続く

        @initialized = true
        self
      end

      # name = "example.com"
      def resolv(name)
        candidates = generate_candidates(name)
        # [#<Resolv::DNS::Name: example.com.>, #<Resolv::DNS::Name: example.com.local.>]

        timeouts = @timeouts || generate_timeouts
        # [5, 3, 6, 12]

        timeout_error = false

        begin
          candidates.each {|candidate|
            begin
              timeouts.each {|tout|
                # @nameserver_port = [["****:***:****:*::*", 53], ["****:***:****:*::*", 53], ["***.***.*.*", 53]]
                # lazy_initializeで初期化済み
                @nameserver_port.each {|nameserver, port|
                  begin
                    # candidate  = #<Resolv::DNS::Name: cloudflare.com.>
                    # tout       = 5
                    # nameserver = "****:***:****:*::*"
                    # port       = 53
                    yield candidate, tout, nameserver, port
                    # yieldの中身はfetch_resourceの中で@config.resolvを呼び出している箇所のブロック
                  rescue ResolvTimeout
                  end
                }
              }
              timeout_error = true
              raise ResolvError.new("DNS resolv timeout: #{name}")
            rescue NXDomain
            end
          }
        rescue ResolvError
          raise if @raise_timeout_errors && timeout_error
        end
      end
    end

    class Requester
      def initialize
        @senders = {}
        @socks = nil
      end

      # (sender)
      # #<Resolv::DNS::Requester::UnconnectedUDP:0x00000001264a9620
      #   @senders={}, @socks=nil,
      #   @nameserver_port=[
      #     ["****:***:****:*::*", 53],
      #     ["****:***:****:*::*", 53],
      #     ["***.***.*.*", 53]
      #   ],
      #   @initialized=false, @mutex=#<Thread::Mutex:0x0000000125db8898>>
      def request(sender, tout)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        timelimit = start + tout

        begin
          sender.send # UDPSocket#sendを呼ぶ
        rescue Errno::EHOSTUNREACH, # multi-homed IPv6 may generate this
               Errno::ENETUNREACH
          raise ResolvTimeout
        end

        while true
          before_select = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          timeout = timelimit - before_select

          if timeout <= 0
            raise ResolvTimeout
          end

          if @socks.size == 1
            select_result = @socks[0].wait_readable(timeout) ? [ @socks ] : nil
          else
            select_result = IO.select(@socks, nil, nil, timeout)
          end

          if !select_result
            after_select = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            next if after_select < timelimit
            raise ResolvTimeout
          end

          begin
            reply, from = recv_reply(select_result[0]) # UDPSocket#recvfromを呼ぶ

          rescue Errno::ECONNREFUSED, # GNU/Linux, FreeBSD
                 Errno::ECONNRESET # Windows
            # No name server running on the server?
            # Don't wait anymore.
            raise ResolvTimeout
          end

          begin
            msg = Message.decode(reply)
          rescue DecodeError
            next # broken DNS message ignored
          end
          if sender == sender_for(from, msg)
            break
          else
            # unexpected DNS message ignored
          end
        end
        return msg, sender.data
      end
    end

    class Message
      def Message.decode(m)
        o = Message.new(0)
        MessageDecoder.new(m) {|msg|
          id, flag, qdcount, ancount, nscount, arcount = msg.get_unpack('nnnnnn')

          o.id = id
          o.tc = (flag >> 9) & 1
          o.rcode = flag & 15
          return o unless o.tc.zero?

          o.qr = (flag >> 15) & 1
          o.opcode = (flag >> 11) & 15
          o.aa = (flag >> 10) & 1
          o.rd = (flag >> 8) & 1
          o.ra = (flag >> 7) & 1

          (1..qdcount).each {
            name, typeclass = msg.get_question
            o.add_question(name, typeclass)
          }
          (1..ancount).each {
            name, ttl, data = msg.get_rr
            o.add_answer(name, ttl, data)
          }
          (1..nscount).each {
            name, ttl, data = msg.get_rr
            o.add_authority(name, ttl, data)
          }
          (1..arcount).each {
            name, ttl, data = msg.get_rr
            o.add_additional(name, ttl, data)
          }
        }
        return o
      end
    end
  end
end
```
