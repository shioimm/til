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


### `Hosts#initialize`

```ruby
 def initialize(filename = DefaultFileName) # DefaultFileName = hosts || '/etc/hosts'
   @filename = filename
   @mutex = Thread::Mutex.new
   @initialized = nil
 end
```

### `DNS#initialize`

```ruby
def initialize(config_info=nil)
  @mutex = Thread::Mutex.new
  @config = Config.new(config_info) # => Config#initialize
  @initialized = nil
end
```

### `Config#initialize`

```ruby
def initialize(config_info=nil)
  @mutex = Thread::Mutex.new
  @config_info = config_info
  @initialized = nil
  @timeouts = nil
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
  if use_ipv6? # => DNS#use_ipv6?
    each_resource(name, Resource::IN::AAAA) { |resource| # => DNS#each_resource WIP
      yield resource.address
    }
  end

  each_resource(name, Resource::IN::A) { |resource| # => DNS#each_resource
    yield resource.address
  }
end

# DNS#use_ipv6?

def use_ipv6? # :nodoc:
  unless @config.instance_variable_get(:@initialized) # @initialized = DNS.newの時点ではnil
    @config.lazy_initialize # => Config#lazy_initialize
  end

  use_ipv6 = @config.use_ipv6? # => Config#use_ipv6?

  # Config#use_ipv6?
  #
  #   def use_ipv6?
  #     @use_ipv6
  #   end

  if !use_ipv6.nil?
    return use_ipv6 # 明示的にIPv6を利用する意思がある場合はその意思を尊重してここでreturn
  end

  begin
    list = Socket.ip_address_list # ローカルの IP アドレスを取得
  rescue NotImplementedError
    return true
  end

  # 利用できるIPv6アドレスがあるかどうか == IPv6対応環境かどうか
  # (shioimm) TODO IPv6-only環境かどうかを確認する方法も必要そう
  list.any? {|a| a.ipv6? && !a.ipv6_loopback? && !a.ipv6_linklocal? }
end
```

### `Config#lazy_initialize`

```ruby
def lazy_initialize
  @mutex.synchronize {

    unless @initialized
      @nameserver_port = [] # 問い合わせ先フルリゾルバの一覧
      @use_ipv6 = nil       # IPv6を使うかどうか
      @search = nil         # DNS検索ドメインのリスト
      @ndots = 1            # 名前の中のドット数の閾値

      # config_hashの構築
      case @config_info
      when nil # デフォルト (/etc/resolv.confなどを利用する)
        config_hash = Config.default_config_hash
      when String # 明示的に指定したresolv.confなどを利用する
        config_hash = Config.parse_resolv_conf(@config_info)
      when Hash # 明示的に指定した設定値を利用する場合
        config_hash = @config_info.dup

        if String === config_hash[:nameserver]
          config_hash[:nameserver] = [config_hash[:nameserver]]
        end

        if String === config_hash[:search]
          config_hash[:search] = [config_hash[:search]]
        end
      else
        raise ArgumentError.new("invalid resolv configuration: #{@config_info.inspect}")
      end

      # --- config_hash から値を取り出す ---
      if config_hash.include? :nameserver
        @nameserver_port = config_hash[:nameserver].map {|ns| [ns, Port] }
      end

      if config_hash.include? :nameserver_port
        @nameserver_port = config_hash[:nameserver_port].map {|ns, port| [ns, (port || Port)] }
      end

      # e.g.
      #   Resolv::DNS.new(nameserver: ['8.8.8.8'], use_ipv6: true)
      # みたいな呼び出しをするとuse_ipv6? => trueになる
      if config_hash.include? :use_ipv6
        @use_ipv6 = config_hash[:use_ipv6]
      end

      @search = config_hash[:search] if config_hash.include? :search
      @ndots = config_hash[:ndots] if config_hash.include? :ndots
      @raise_timeout_errors = config_hash[:raise_timeout_errors]

      if @nameserver_port.empty?
        #  フルリゾルバが1つも設定されていない場合は0.0.0.0を利用
        @nameserver_port << ['0.0.0.0', Port]
      end

      # --- 検索ドメインの正規化 ---
      if @search
        @search = @search.map {|arg| Label.split(arg) }
      else
        hostname = Socket.gethostname
        if /\./ =~ hostname
          @search = [Label.split($')]
        else
          @search = [[]]
        end
      end

      # --- バリデーションチェック ---
      if !@nameserver_port.kind_of?(Array) ||
         @nameserver_port.any? { |ns_port|
            !(Array === ns_port) ||
            ns_port.length != 2
            !(String === ns_port[0]) ||
            !(Integer === ns_port[1])
         }
        raise ArgumentError.new("invalid nameserver config: #{@nameserver_port.inspect}")
      end

      if !@search.kind_of?(Array) ||
         !@search.all? {|ls| ls.all? {|l| Label::Str === l } }
        raise ArgumentError.new("invalid search config: #{@search.inspect}")
      end

      if !@ndots.kind_of?(Integer)
        raise ArgumentError.new("invalid ndots config: #{@ndots.inspect}")
      end

      @initialized = true
    end
  }
  self
end
```

### `DNS#each_resource`

```ruby
# name = ドメイン名
# typeclass = レコードの種類 (e.g. Resource::IN::AAAA)
def each_resource(name, typeclass, &proc)
  fetch_resource(name, typeclass) {|reply, reply_name| # => DNS#fetch_resource
    extract_resources(reply, reply_name, typeclass, &proc) # => DNS#extract_resources
  }
end

# DNS#fetch_resource WIP

def fetch_resource(name, typeclass)
  lazy_initialize # => DNS#lazy_initialize
  truncated = {}
  requesters = {}

  udp_requester =
    begin
      make_udp_requester # => DNS#make_udp_requester
      # Requester::ConnectedUDP もしくは Requester::UnconnectedUDPオブジェクトを作成してudp_requesterに格納
    rescue Errno::EACCES
      # fall back to TCP
    end

  senders = {}

  begin
    @config.resolv(name) do |candidate, tout, nameserver, port| # => Config#resolv
      # --- WIP ---
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

# DNS#make_udp_requester

def make_udp_requester # :nodoc:
  nameserver_port = @config.nameserver_port # => DNS#nameserver_port

  # DNS#nameserver_port
  #   def nameserver_port
  #     @nameserver_port
  #   end

  if nameserver_port.length == 1
    Requester::ConnectedUDP.new(*nameserver_port[0]) # => Requester::ConnectedUDP#initialize
  else
    Requester::UnconnectedUDP.new(*nameserver_port) # => Requester::UnconnectedUDP#initialize
  end
end

# DNS#extract_resources WIP

def extract_resources(msg, name, typeclass) # :nodoc:
  if typeclass < Resource::ANY
    n0 = Name.create(name)
    msg.each_resource {|n, ttl, data|
      yield data if n0 == n
    }
  end
  yielded = false
  n0 = Name.create(name)
  msg.each_resource {|n, ttl, data|
    if n0 == n
      case data
      when typeclass
        yield data
        yielded = true
      when Resource::CNAME
        n0 = data.name
      end
    end
  }
  return if yielded
  msg.each_resource {|n, ttl, data|
    if n0 == n
      case data
      when typeclass
        yield data
      end
    end
  }
end
```

### `Requester::ConnectedUDP#initialize`

```ruby
# class ConnectedUDP < Requester

 def initialize(host, port=Port)
   super() # => Requester#initialize
   @host = host
   @port = port
   @mutex = Thread::Mutex.new
   @initialized = false
 end
```

### `Requester::UnconnectedUDP#initialize`

```ruby
# class UnconnectedUDP < Requester

def initialize(*nameserver_port)
  super() # => Requester#initialize
  @nameserver_port = nameserver_port
  @initialized = false
  @mutex = Thread::Mutex.new
end
```

### `Requester#initialize`

```ruby
def initialize
  @senders = {}
  @socks = nil
end
```

### `Config#resolv`

```ruby
def resolv(name)
  candidates = generate_candidates(name) # => Config#generate_candidates
  timeouts = @timeouts || generate_timeouts # => Config#generate_timeouts
  timeout_error = false

  begin
    candidates.each {|candidate|
      begin
        timeouts.each { |tout|
          @nameserver_port.each {|nameserver, port|
            begin
              # Config#resolvのブロックに
              # - candidate  = 実際にDNSへ問い合わせるドメイン名を表すDNS::Nameオブジェクト
              # - tout       = タイムアウト秒
              # - nameserver = フルリゾルバのIPアドレス
              # - port       = フルリゾルバのポート番号
              # を渡す
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

# Config#generate_candidates

def generate_candidates(name)
  candidates = nil
  name = Name.create(name) # => DNS::Name.create 解決したいドメイン名をDNS::Nameオブジェクトにする

  if name.absolute? # => DNS::Name#absolute? デフォルトでtrue
    # DNS::Name#absolute?
    #
    #   def absolute?
    #     return @absolute
    #   end
    candidates = [name] # FQDNの場合はそのまま名前解決を行う候補として扱う
  else
    if @ndots <= name.length - 1
      candidates = [Name.new(name.to_a)] # @ndot <= .の数 の場合はそのまま名前解決を行う候補として扱う
    else
      candidates = [] # @ndot > .の数 の場合は検索ドメインを試すため候補リストを空に初期化
    end

    # @searchの各ドメインを名前の末尾に連結した候補を追加
    candidates.concat(@search.map { |domain| Name.new(name.to_a + domain) }) # => DNS::Name#initialize

    # 名前に.を付けてFQDNにしたものを最後の候補として追加
    fname = Name.create("#{name}.") # => DNS::Name.create

    if !candidates.include?(fname)
      candidates << fname
    end
  end
  return candidates
end

# Config#generate_timeouts

InitialTimeout = 5

def generate_timeouts
  ts = [InitialTimeout]
  ts << ts[-1] * 2 / @nameserver_port.length
  ts << ts[-1] * 2
  ts << ts[-1] * 2
  return ts
end
```

### `DNS::Name.create`

```ruby
def self.create(arg)
  case arg
  when Name
    return arg
  when String
    labels = Label.split(arg) # => DNS::Label.split

    # Label.split ドメイン名を.で分割し、各部分をLabel::Strオブジェクトの配列にする
    #
    #   def self.split(arg)
    #     labels = []
    #     arg.scan(/[^\.]+/) { labels << Str.new($&) } # => DNS::Label::Str#initialize
    #     return labels
    #   end

    # Label::Str#initialize
    #
    #   def initialize(string)
    #     @string = string
    #     @downcase = string.b.downcase
    #   end

    return Name.new(labels, /\.\z/ =~ arg ? true : false) # => DNS::Name#initialize
  else
    raise ArgumentError.new("cannot interpret as DNS name: #{arg.inspect}")
  end
end

# DNS::Name#initialize

def initialize(labels, absolute=true) # :nodoc:
  labels = labels.map {|label|
    case label
    when String then Label::Str.new(label) # => DNS::Label::Str#initialize
    when Label::Str then label
    else
      raise ArgumentError, "unexpected label: #{label.inspect}"
    end
  }

  @labels = labels
  @absolute = absolute
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
