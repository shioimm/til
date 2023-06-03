# 実装
- https://github.com/ruby/resolv/blob/master/lib/resolv.rb

```ruby
Resolv.getaddress("example.com")
```

```ruby
# Resolv

def self.each_address(name, &block)
  DefaultResolver.each_address(name, &block)
end


def getaddress(name)
  each_address(name) {|address| return address}
  raise ResolvError.new("no address for #{name}")
end

def each_address(name)
  # ...
  yielded = false
  @resolvers.each {|r|
    r.each_address(name) {|address|
      yield address.to_s
      yielded = true
    }
    return if yielded
  }
end
```

```ruby
@resolvers # Array
=>
[#<Resolv::Hosts:0x0000000104cdda98>,
  @filename="/etc/hosts",
  @initialized=nil,
  @mutex=#<Thread::Mutex:0x0000000104cdda20>>,
 #<Resolv::DNS:0x0000000104cdd9d0
  @config=
   #<Resolv::DNS::Config:0x0000000104cdd930
    @config_info=nil,
    @initialized=nil,
    @mutex=#<Thread::Mutex:0x0000000104cdd8e0>,
    @timeouts=nil>,
  @initialized=nil,
  @mutex=#<Thread::Mutex:0x0000000104cdd980>>]
```

### `self`が`Resolv::Hosts`のインスタンスの場合
- `Resolv::Hosts`の`@filename`で名前解決できる場合

```ruby
# Resolv::Hosts

def each_address(name, &proc)
  lazy_initialize
  # => Resolv::Hosts#lazy_initialize: mutexの中で@filenameを利用して@name2addr、@addr2nameに値を入れる

  # proc = <Proc:0x00000001074c9de0 /path/to/ruby/3.2.0/resolv.rb:116> (Resolv#each_addressのブロック)
  # @name2addr[name] で値が取得できる場合、それがprocのブロック引数になる
  @name2addr[name]&.each(&proc)
end
```

### `self`が`Resolv::DNS`のインスタンスの場合

```ruby
# Resolv::DNS

def each_address(name)
  each_resource(name, Resource::IN::A) {|resource| yield resource.address}
  if use_ipv6?
    each_resource(name, Resource::IN::AAAA) {|resource| yield resource.address}
  end
end

# ...

# name: "example.com" / typeclass: Resolv::DNS::Resource::IN::A
def each_resource(name, typeclass, &proc)
  fetch_resource(name, typeclass) {|reply, reply_name|
    extract_resources(reply, reply_name, typeclass, &proc)
  }
end

def fetch_resource(name, typeclass)
  lazy_initialize
  # => mutexの中でResolv::DNS::Config#lazy_initializeを実行

  begin
    requester = make_udp_requester
    # => requester: Resolv::DNS::Requester::ConnectedUDPインスタンス
    #    (@configのnameserver_portの数によってはRequester::UnconnectedUDPインスタンス
  rescue Errno::EACCES
    # fall back to TCP
  end

  senders = {}

  begin
    @config.resolv(name) {|candidate, tout, nameserver, port|
      # ...
    }
  ensure
    requester&.close
  end
end
```

```ruby
# Resolv::DNS::Config

def resolv(name)
  candidates = generate_candidates(name)
  # ...
end

def generate_candidates(name)
  candidates = nil
  name = Name.create(name)
  # => #<Resolv::DNS::Name: example.com.>を生成
  # ...

  candidates = [Name.new(name.to_a)]
  # => candidates: [#<Resolv::DNS::Name: example.com.>]

  candidates.concat(@search.map {|domain| Name.new(name.to_a + domain)})
  # => candidates: [#<Resolv::DNS::Name: example.com.>, #<Resolv::DNS::Name: example.com.local.>]

  # ...
  return candidates
end
```

```ruby
def resolv(name)
  candidates = generate_candidates(name)
  # candidates: [#<Resolv::DNS::Name: example.com.>, #<Resolv::DNS::Name: example.com.local.>]

  timeouts = @timeouts || generate_timeouts
  # => timeouts: generate_timeoutsが呼ばれた場合 [5, 10, 20, 40]

  begin
    candidates.each {|candidate|
      begin
        timeouts.each {|tout|
          # @nameserver_port: [["<IPアドレス>", <ポート番号>]] のような配列
          @nameserver_port.each {|nameserver, port|
            begin
              yield candidate, tout, nameserver, port
            rescue ResolvTimeout
            end
          }
        }
        raise ResolvError.new("DNS resolv timeout: #{name}")
      rescue NXDomain
      end
    }
  rescue ResolvError
  end
end
```

```ruby
# Resolv::DNS

def fetch_resource(name, typeclass)
  # ...
  senders = {}

  begin
    @config.resolv(name) {|candidate, tout, nameserver, port|
      # ...

      msg = Message.new
      # => #<Resolv::DNS::Message:0x0000000105c07f00
      #       @aa=0,
      #       @additional=[],
      #       @answer=[],
      #       @authority=[],
      #       @id=0,
      #       @opcode=0,
      #       @qr=0,
      #       @question=[],
      #       @ra=0,
      #       @rcode=0,
      #       @rd=0,
      #       @tc=0>

      msg.rd = 1
      msg.add_question(candidate, typeclass)
      # => @question << [Name.create(candidate), typeclass]

      unless sender = senders[[candidate, nameserver, port]]
        # nameserverはConfig.default_config_hashから (デフォルトでは/etc/resolv.confを読み込み)
        # portはResolv::DNS::Portから

        sender = requester.sender(msg, candidate, nameserver, port)
        next if !sender
        senders[[candidate, nameserver, port]] = sender
      end

      # ...
    }
  end
end
```

```ruby
# Resolv::DNS::Requester::ConnectedUDP

def sender(msg, data, host=@host, port=@port)
  lazy_initialize
  # ...
  id = DNS.allocate_request_id(@host, @port)
  request = msg.encode
  request[0,2] = [id].pack('n')

  # Sender.new(request, data, @socks[0])
  # => #<Resolv::DNS::Requester::ConnectedUDP::Sender:0x00000001087ff7e8
  #      @data=#<Resolv::DNS::Name: example.com.>,
  #      @msg="\x10\x96\x01\x00\x00\x01\x00\x00\x00\x00\x00\x00\aexample\x03com\x00\x00\x01\x00\x01",
  #      @sock=#<UDPSocket:fd 9, AF_INET, <@host>, <#bind_random_portでバインドされた適当なポート>>>}

  return @senders[[nil,id]] = Sender.new(request, data, @socks[0])
end

def lazy_initialize
  @mutex.synchronize {
    next if @initialized
    @initialized = true
    is_ipv6 = @host.index(':')
    sock = UDPSocket.new(is_ipv6 ? Socket::AF_INET6 : Socket::AF_INET)
    @socks = [sock]
    sock.do_not_reverse_lookup = true
    DNS.bind_random_port(sock, is_ipv6 ? "::" : "0.0.0.0") # UDPソケットを適当なポートへバインド
    sock.connect(@host, @port) # => UDPでフルリゾルバへ接続を開始
  }
  self
end
```

```ruby
def fetch_resource(name, typeclass)
  # ...
  begin
    @config.resolv(name) {|candidate, tout, nameserver, port|
      # ...

      unless sender = senders[[candidate, nameserver, port]]
        # ...
      end

      reply, reply_name = requester.request(sender, tout)
      # ...
    }
  ensure
    requester&.close
  end
end
```

```ruby
# Resolv::DNS::Requester

def request(sender, tout)
  start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  timelimit = start + tout

  begin
    sender.send # Resolv::DNS::Requester::ConnectedUDP::Sender#send (@sock.send(@msg, 0) するだけ)
  rescue Errno::EHOSTUNREACH, # multi-homed IPv6 may generate this
         Errno::ENETUNREACH
    raise ResolvTimeout
  end

  while true
    before_select = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    timeout = timelimit - before_select

    # フルリゾルバからのレスポンスが返ってくる前にタイムアウトした場合の処理
    if timeout <= 0
      raise ResolvTimeout
    end

    # 受信したメッセージを読み取るソケットを特定
    if @socks.size == 1
      select_result = @socks[0].wait_readable(timeout) ? [ @socks ] : nil
    else
      select_result = IO.select(@socks, nil, nil, timeout)
    end

    # ...

    begin
      reply, from = recv_reply(select_result[0])
      # => reply: select_result[0].recv(UDPSize), from: nil
    rescue Errno::ECONNREFUSED, # GNU/Linux, FreeBSD
           Errno::ECONNRESET # Windows
      # No name server running on the server?
      # Don't wait anymore.
      raise ResolvTimeout
    end

    begin
      msg = Message.decode(reply)
      # => msgにreplyをデコードした結果を格納するResolv::DNS::Messageインスタンスを代入
    rescue DecodeError
      next # broken DNS message ignored
    end
    if sender == sender_for(from, msg)
      break
    else
      # unexpected DNS message ignored
    end
  end

  # return #<Resolv::DNS::Message:0x0000000108e8f018 ...>, #<Resolv::DNS::Name: example.com.>
  return msg, sender.data
end
```

```ruby
def fetch_resource(name, typeclass)
  # ...
  begin
    @config.resolv(name) {|candidate, tout, nameserver, port|
      # ...
      reply, reply_name = requester.request(sender, tout)

      case reply.rcode
      when RCode::NoError
        # ...
        yield(reply, reply_name)
        return
      # ...
      end
    }
  ensure
    requester&.close
  end
end
```

```ruby
# Resolv::DNS

def each_resource(name, typeclass, &proc)
  # Resolv::DNS#fetch_resourceを呼び出していた箇所
  fetch_resource(name, typeclass) {|reply, reply_name|
    # reply:      #<Resolv::DNS::Message:0x0000000108e8f018 ...>
    # reply_name: #<Resolv::DNS::Name: example.com.>
    # typeclass:  Resolv::DNS::Resource::IN::A
    # proc:       (元々の呼び出し) each_resource(name, Resource::IN::A) {|resource| yield resource.address}
    extract_resources(reply, reply_name, typeclass, &proc)
  }
end

def extract_resources(msg, name, typeclass) # :nodoc:
  # ...
  yielded = false
  n0 = Name.create(name)

  msg.each_resource {|n, ttl, data|
    # n:    #<Resolv::DNS::Name: example.com.>
    # ttl : 1540
    # data: #<Resolv::DNS::Resource::IN::A:0x0000000103b21890 @address=#<Resolv::IPv4 *.*.*.*>, @ttl=1540>

    if n0 == n
      case data
      when typeclass # <= ここを通る
        yield data
        # => Resolv::DNS#each_addressで呼び出しているResolv::DNS#each_resourceのブロックを実行
        #      # Resolv::DNS
        #      # def each_address(name)
        #      #   each_resource(name, Resource::IN::A) { |resource|
        #      #     yield resource.address # resource.address: #<Resolv::IPv4 *.*.*.*>
        #      #     # => Resolv#each_addressが呼んでいるResolv::DNS#each_addressのブロックを実行
        #      #    }
        #      #  end

        #      # Resolv::DNS#each_address
        #      def each_address(name)
        #        # ...
        #        @resolvers.each {|r|
        #          r.each_address(name) {|address|
        #            yield address.to_s # ここでResolv::IPv4のアドレスを文字列に変換
        #            # => Resolv#getaddressが呼んでいるResolv#each_addressのブロックを実行
        #            yielded = true
        #          }
        #          return if yielded
        #        }
        #      end

        #      # Resolv
        #      def getaddress(name)
        #        each_address(name) {|address| return address}
        #        raise ResolvError.new("no address for #{name}")
        #      end

        yielded = true
      when Resource::CNAME
        n0 = data.name
      end
    end
  }
  # ...
end
```

```ruby
# Resolv::DNS::Message

def each_resource
  # 各ブロック内のyieldでResolv::DNS#each_resourceのブロックを実行している
  each_answer {|name, ttl, data| yield name, ttl, data}
  each_authority {|name, ttl, data| yield name, ttl, data}
  each_additional {|name, ttl, data| yield name, ttl, data}
end

def each_answer
  @answer.each {|name, ttl, data|
    yield name, ttl, data
  }
end

def each_authority
  @authority.each {|name, ttl, data|
    yield name, ttl, data
  }
end

def add_additional(name, ttl, data)
  @additional << [Name.create(name), ttl, data]
end
```
