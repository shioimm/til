# 実装
- https://github.com/ruby/resolv/blob/master/lib/resolv.rb

```ruby
Resolv.getaddress("example.com")
```

- `Resolv.getaddress` -> `Resolv#getaddress` -> `Resolv#each_address`

```ruby
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
      requester ||= make_tcp_requester(nameserver, port)
      msg = Message.new
      msg.rd = 1
      msg.add_question(candidate, typeclass)

      unless sender = senders[[candidate, nameserver, port]]
        sender = requester.sender(msg, candidate, nameserver, port)
        next if !sender
        senders[[candidate, nameserver, port]] = sender
      end

      reply, reply_name = requester.request(sender, tout)
      case reply.rcode
      when RCode::NoError
        # ...
        yield(reply, reply_name) # Resolv::DNS#extract_resourcesに引数reply, reply_nameを渡して実行
        return
      # ...
      end
    }
  ensure
    requester&.close
  end
end

def extract_resources(msg, name, typeclass) # :nodoc:
  # WIP
end
```
