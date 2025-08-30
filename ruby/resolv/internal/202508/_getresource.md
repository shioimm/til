# `Resolv::DNS#getresources`

```ruby
require "resolv"
dns = Resolv::DNS.new
dns.getresources("example.com", Resolv::DNS::Resource::IN::NS)

# [
#   #<Resolv::DNS::Resource::IN::NS:0x000000011c739db8 @name=#<Resolv::DNS::Name: a.iana-servers.net.>, @ttl=86400>,
#   ...
# ]

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
    # typeclass = Resolv::DNS::Resource::IN::NS
    def getresources(name, typeclass)
      ret = []
      each_resource(name, typeclass) {|resource| ret << resource}
      return ret
    end

    # name      = "example.com"
    # typeclass = Resolv::DNS::Resource::IN::NS
    # &proc     = {|resource| ret << resource}
    def each_resource(name, typeclass, &proc)
      fetch_resource(name, typeclass) {|reply, reply_name|
        extract_resources(reply, reply_name, typeclass, &proc)
      }
    end

    # name      = "example.com"
    # typeclass = Resolv::DNS::Resource::IN::NS
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
        # ----------------- WIP @config.resolvを読んでいる最中 ----------------------
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
                # ----------------- WIP ここまで読んだ ----------------------
                @nameserver_port.each {|nameserver, port|
                  begin
                    yield candidate, tout, nameserver, port
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
  end
end
```
