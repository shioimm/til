# Resolv.getaddresses
- https://github.com/ruby/resolv/blob/master/lib/resolv.rb

```ruby
Resolv.getaddress("www.ruby-lang.org")
```

```ruby
# Resolv.getaddresses
def self.getaddresses(name)
  DefaultResolver.getaddresses(name)
  # DefaultResolver = self.new
  # => Resolv#initialize
  # => Resolv#getaddresses
end

# Resolv#initialize
def initialize(resolvers = (arg_not_set = true; nil), use_ipv6: (keyword_not_set = true; nil))
  # resolversが明示的に指定されている場合arg_not_setはnil、そうでなければtrue
  # use_ipv6が明示的に指定されている場合keyword_not_setはnil、そうでなければtrue↲

  # resolversとuse_ipv6を両方渡した場合、use_ipv6は無視
  # use_ipv6は実際には使われていない。将来的にはデフォルトのDNSリゾルバを内部構築するフラグになる?
  if !keyword_not_set && !arg_not_set
    warn "Support for separate use_ipv6 keyword is deprecated,
          as it is ignored if an argument is provided.
          Do not provide a positional argument if using the use_ipv6 keyword argument.", uplevel: 1
  end

  # resolversをResolv.new(nameserver: ["8.8.8.8"])みたいにするとwhen Hashのブロックに入る

  @resolvers =
    case resolvers
    when Hash, nil
      config = DNS::Config.default_config_hash.merge(resolvers || {})
      # => DNS::Config.default_config_hash

      [Hosts.new, DNS.new(config)]
      # => Hosts#initialize
      # => DNS#initialize
    else
      resolvers
    end
end

# Resolv#getaddresses
def getaddresses(name)
  ret = []
  each_address(name) { |address| ret << address } # => Resolv#each_address
  return ret
end

# Resolv#each_address
# WIP
def each_address(name)
  if AddressRegex =~ name
    yield name
    return
  end

  yielded = false

  @resolvers.each { |r|
    r.each_address(name) { |address|
      yield address.to_s
      yielded = true
    }
    return if yielded
  }
end

```
