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

- `self`が`Resolv::Hosts`のインスタンスの場合:

```ruby
def each_address(name, &proc)
  lazy_initialize
  @name2addr[name]&.each(&proc)
end

# lazy_initialize実行後、@addr2name、@mutex、@name2addrに値が入る

def lazy_initialize # :nodoc:
  @mutex.synchronize {
    unless @initialized
      @config.lazy_initialize
      @initialized = true
    end
  }
  self
end
```

- `self`が`Resolv::DNS`のインスタンスの場

```ruby
def each_address(name)
  each_resource(name, Resource::IN::A) {|resource| yield resource.address}
  if use_ipv6?
    each_resource(name, Resource::IN::AAAA) {|resource| yield resource.address}
  end
end
```
