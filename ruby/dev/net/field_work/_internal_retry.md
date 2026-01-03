# net-http 現地調査 (net-http-0.9.1時点)
## 気づいたこと
- デフォルトでは暗黙的に1回リトライする
- 明示的にリトライしたい場合は`HTTP#max_retries=`を利用する

## リトライの設定
### 明示的なリトライ
- `HTTP#max_retries=`を設定する

```ruby
# HTTP#max_retries= (lib/net/http.rb)

def max_retries=(retries)
  retries = retries.to_int

  if retries < 0
    raise ArgumentError, 'max_retries should be non-negative integer number'
  end

  @max_retries = retries # リトライ回数の設定
end
```

### 暗黙的なリトライ

```ruby
# HTTP#initialize (lib/net/http.rb)

def initialize(address, port = nil) # :nodoc:
  defaults = {
    keep_alive_timeout: 2,
    close_on_empty_response: false,
    open_timeout: 60,
    read_timeout: 60,
    write_timeout: 60,
    continue_timeout: nil,
    max_retries: 1, # デフォルトのリトライ回数1回
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
  @max_retries = options[:max_retries] # リトライ回数の設定
  @debug_output = options[:debug_output]
  @response_body_encoding = options[:response_body_encoding]
  @ignore_eof = options[:ignore_eof]
  @tcpsocket_supports_open_timeout = nil

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
```

## リトライを実行する

```ruby
# HTTP#transport_request (lib/net/http.rb)

attr_reader :max_retries

def transport_request(req)
  count = 0
  begin
    begin_transport req

    res = catch(:response) {
      begin
        req.exec(@socket, @curr_http_version, edit_path(req.path))
      rescue Errno::EPIPE
        # Failure when writing full request, but we can probably
        # still read the received response.
      end

      begin
        res = HTTPResponse.read_new(@socket)
        res.decode_content = req.decode_content
        res.body_encoding = @response_body_encoding
        res.ignore_eof = @ignore_eof
      end while res.kind_of?(HTTPInformation)

      res.uri = req.uri

      res
    }

    res.reading_body(@socket, req.response_body_permitted?) {
      if block_given?
        count = max_retries # Don't restart in the middle of a download
        yield res
      end
    }
  rescue Net::OpenTimeout
    raise
  rescue Net::ReadTimeout,
         IOError,
         EOFError,
         Errno::ECONNRESET,
         Errno::ECONNABORTED,
         Errno::EPIPE,
         Errno::ETIMEDOUT,
         defined?(OpenSSL::SSL) ? OpenSSL::SSL::SSLError : IOError, # avoid a dependency on OpenSSL
         Timeout::Error => exception

    # IDEMPOTENT_METHODS_ = %w/GET HEAD PUT DELETE OPTIONS TRACE/.freeze
    if count < max_retries && IDEMPOTENT_METHODS_.include?(req.method) # リトライする
      count += 1
      @socket.close if @socket
      debug "Conn close because of error #{exception}, and retry"
      retry
    end

    debug "Conn close because of error #{exception}"
    @socket.close if @socket
    raise
  end

  end_transport(req, res)
  res
rescue => exception
  debug "Conn close because of error #{exception}"
  @socket.close if @socket
  raise exception
end
```
