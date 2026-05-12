# Resolv.getaddresses
- https://github.com/ruby/resolv/blob/master/lib/resolv.rb

```ruby
Resolv.getaddress("www.ruby-lang.org")
```

```ruby
# Resolv.getaddresses
def self.getaddresses(name)
  DefaultResolver.getaddresses(name) # DefaultResolver = self.new
  # => Resolv#initialize
  # => Resolv#getaddresses
end
```

### `Resolv#initialize`

```ruby
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
      # 前者はローカルで名前解決するためのもの、後者はDNSを利用するためのもの

      # => Hosts#initialize
      # => DNS#initialize

      #  (Hosts#initialize)
      #
      #    def initialize(filename = DefaultFileName) # DefaultFileName = hosts || '/etc/hosts'
      #      @filename = filename
      #      @mutex = Thread::Mutex.new
      #      @initialized = nil
      #    end
      #
      #  (DNS#initialize)
      #
      #    def initialize(config_info=nil)
      #      @mutex = Thread::Mutex.new
      #      @config = Config.new(config_info)
      #      @initialized = nil
      #    end
    else
      resolvers
    end
end
```

### DNS::Config.default_config_hash

```ruby
def Config.default_config_hash(filename="/etc/resolv.conf")
  if File.exist? filename
    Config.parse_resolv_conf(filename) # => Config.parse_resolv_conf
  elsif defined?(Win32::Resolv)
    search, nameserver = Win32::Resolv.get_resolv_info
    config_hash = {}
    config_hash[:nameserver] = nameserver if nameserver
    config_hash[:search] = [search].flatten if search
    config_hash
  else
    {}
  end
end

# Config.parse_resolv_conf
def Config.parse_resolv_conf(filename)
  nameserver = [] #  DNSサーバのIPアドレス
  search = nil
  ndots = 1

  File.open(filename, 'rb') {|f| # デフォルトではfilename = "/etc/resolv.conf"
    # e.g.
    #   nameserver 8.8.8.8
    #   nameserver 8.8.4.4
    #   search example.com local
    #   options ndots:5
    #   => { nameserver: ["8.8.8.8", "8.8.4.4"], search: ["example.com", "local"], ndots: 5 }

    f.each { |line|
      line.sub!(/[#;].*/, '')
      keyword, *args = line.split(/\s+/)

      next unless keyword

      case keyword
      when 'nameserver'
        nameserver.concat(args.each(&:freeze))
      when 'domain'
        next if args.empty?
        search = [args[0].freeze]
      when 'search'
        next if args.empty?
        search = args.each(&:freeze)
      when 'options'
        args.each {|arg|
          case arg
          when /\Andots:(\d+)\z/
            ndots = $1.to_i
          end
        }
      end
    }
  }

  return { :nameserver => nameserver.freeze, :search => search.freeze, :ndots => ndots.freeze }.freeze
end
```

### `Resolv#getaddresses`

```ruby
def getaddresses(name)
  ret = []
  each_address(name) { |address| ret << address } # => Resolv#each_address
  return ret
end

# Resolv#each_address
def each_address(name)
  # AddressRegex = /(?:#{IPv4::Regex})|(?:#{IPv6::Regex})/
  # IPv4::RegexとIPv6::RegexはそれぞれIPv4クラス / IPv6クラスに自前実装がある
  if AddressRegex =~ name
    yield name # 渡された文字列がIPアドレスリテラルの場合、そのままブロックを実行して終了
    return
  end

  yielded = false

  @resolvers.each { |r| # @resolversは[Hosts.new, DNS.new(config)]もしくは任意のリゾルバオブジェクト
    r.each_address(name) { |address| # => Hosts#each_address or DNS#each_address or MDNS#each_address
      yield address.to_s # 取得したアドレスをわたしてブロックを実行
      yielded = true
    }
    return if yielded
  }
end
```

### `Hosts#each_address`

```ruby
def each_address(name, &proc)
  lazy_initialize # => Hosts#lazy_initialize 他のパブリックAPIも呼んでいる (なので@initializedで初期化を確認する)
  @name2addr[name]&.each(&proc) # @name2addr に収集したホスト名からアドレスを引き、ブロックを実行
end

# Hosts#lazy_initialize
def lazy_initialize # :nodoc:
  @mutex.synchronize {
    unless @initialized # Hosts#initializeの時点では @initialized = nil
      @name2addr = {} # { ホスト名 => [アドレス] } 形式のハッシュ
      @addr2name = {} # { アドレス => [ホスト名] } 形式のハッシュ

      File.open(@filename, 'rb') {|f| # Hosts#initializeの時点では @filename = hosts || '/etc/hosts'
        # /etc/hostsなどのローカルの設定ファイルを読み込んで@name2addrに書き込む
        # e.g.
        #   127.0.0.1   localhost localhost.local
        #   ::1         localhost
        #   ---
        #   addr      = "127.0.0.1"
        #   hostnames = ["localhost", "localhost.local"]
        #   @addr2name["127.0.0.1"]       = ["localhost", "localhost.local"]
        #   @name2addr["localhost"]       = ["127.0.0.1", "::1"]
        #   @name2addr["localhost.local"] = ["127.0.0.1"]

        f.each {|line|
          line.sub!(/#.*/, '')
          addr, *hostnames = line.split(/\s+/)

          next unless addr

          (@addr2name[addr] ||= []).concat(hostnames)
          hostnames.each { |hostname| (@name2addr[hostname] ||= []) << addr }
        }
      }

      @name2addr.each { |name, arr| arr.reverse! }
      @initialized = true
    end
  }
  self
end
```

### `DNS#each_address`

```ruby
def each_address(name)
  if use_ipv6?
    each_resource(name, Resource::IN::AAAA) {|resource| yield resource.address}
  end
  each_resource(name, Resource::IN::A) {|resource| yield resource.address}
end
```

### `MDNS#each_address`

```ruby
# class MDNS < DNS

def each_address(name)
  name = Resolv::DNS::Name.create(name)

  return unless name[-1].to_s == 'local'

  super(name)
end
```
