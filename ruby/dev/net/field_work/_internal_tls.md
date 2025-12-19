# net-http 現地調査: TLS編 (202512時点)

## HTTPSを利用する
- `HTTP#use_ssl=`を利用する

```ruby
uri = URI("https://example.com")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

res = http.get("/")
puts res.body
```

- `use_ssl`オプションを渡す

```ruby
uri = URI.parse("https://example.com/")

Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
  res = http.get("/")
  puts res.body
end
```

## HTTPSを使うための設定を保存する
#### `HTTP#use_ssl=`を利用する場合

```ruby
# HTTP#initialize (lib/net/http.rb)

SSL_ATTRIBUTES = [
  :ca_file,
  :ca_path,
  :cert,
  :cert_store,
  :ciphers,
  :extra_chain_cert,
  :key,
  :ssl_timeout,
  :ssl_version,
  :min_version,
  :max_version,
  :verify_callback,
  :verify_depth,
  :verify_mode,
  :verify_hostname,
] # :nodoc:

SSL_IVNAMES = SSL_ATTRIBUTES.map { |a| "@#{a}".to_sym } # :nodoc:

def initialize(address, port = nil) # :nodoc:
  defaults = {
    keep_alive_timeout: 2,
    close_on_empty_response: false,
    open_timeout: 60,
    read_timeout: 60,
    write_timeout: 60,
    continue_timeout: nil,
    max_retries: 1,
    debug_output: nil,
    response_body_encoding: false,
    ignore_eof: true
  }
  options = defaults.merge(self.class.default_configuration || {})

  @address = address
  @port    = (port || HTTP.default_port)
  @ipaddr = nil
  @local_host = nil
  @local_port = nil
  @curr_http_version = HTTPVersion
  @keep_alive_timeout = options[:keep_alive_timeout]
  @last_communicated = nil
  @close_on_empty_response = options[:close_on_empty_response]
  @socket  = nil
  @started = false
  @open_timeout = options[:open_timeout]
  @read_timeout = options[:read_timeout]
  @write_timeout = options[:write_timeout]
  @continue_timeout = options[:continue_timeout]
  @max_retries = options[:max_retries]
  @debug_output = options[:debug_output]
  @response_body_encoding = options[:response_body_encoding]
  @ignore_eof = options[:ignore_eof]

  @proxy_from_env = false
  @proxy_uri      = nil
  @proxy_address  = nil
  @proxy_port     = nil
  @proxy_user     = nil
  @proxy_pass     = nil
  @proxy_use_ssl  = nil

  @use_ssl = false
  @ssl_context = nil
  @ssl_session = nil
  @sspi_enabled = false

  SSL_IVNAMES.each do |ivname|
    instance_variable_set ivname, nil
  end
end

# HTTP#use_ssl= (lib/net/http.rb)

def use_ssl=(flag)
  flag = flag ? true : false # truthyならtrueになる

  if started? # @started (デフォルトではfalse) => HTTP#started? (lib/net/http.rb)
     and @use_ssl != flag # @use_sslもデフォルトではfalse
    raise IOError, "use_ssl value changed, but session already started"
  end

  @use_ssl = flag
end
```

#### `Net::HTTP.start`に`use_ssl`オプションを渡す

WIP
```ruby
# (lib/net/http.rb)

def HTTP.start(address, *arg, &block) # :yield: +http+
  arg.pop if opt = Hash.try_convert(arg[-1])
  port, p_addr, p_port, p_user, p_pass = *arg
  p_addr = :ENV if arg.size < 2
  port = https_default_port if !port && opt && opt[:use_ssl]
  # 443 => HTTP.https_default_port

  http = new(address, port, p_addr, p_port, p_user, p_pass) # => HTTP#initialize
  http.ipaddr = opt[:ipaddr] if opt && opt[:ipaddr]

  if opt
    if opt[:use_ssl]
      opt = {verify_mode: OpenSSL::SSL::VERIFY_PEER}.update(opt)
    end

    http.methods.grep(/\A(\w+)=\z/) do |meth| # => HTTP#methods (?)
      key = $1.to_sym
      opt.key?(key) or next
      http.__send__(meth, opt[key])
    end
  end

  http.start(&block) # => HTTP#start
end
```
