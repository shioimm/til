# faraday 現地調査 (202511時点)

## 全体の流れ
WIP

## `Faraday.new`

```ruby
# (lib/faraday.rb)

def new(url = nil, options = {}, &block)
  options = Utils.deep_merge(default_connection_options, options)
  # => Faraday.default_connection_options
  # => Utils.deep_merge
  Faraday::Connection.new(url, options, &block) # => Connection#initialize
end

# Faraday.default_connection_options (lib/faraday.rb)

def default_connection_options
  @default_connection_options ||= ConnectionOptions.new # => ConnectionOptions
end
```

### `Utils.deep_merge`

```ruby
# (lib/faraday/utils.rb)

def deep_merge!(target, hash)
  hash.each do |key, value|
    target[key] = if value.is_a?(Hash) && (target[key].is_a?(Hash) || target[key].is_a?(Options))
                    deep_merge(target[key], value)
                  else
                    value
                  end
  end
  target
end
```

## `Connection#initialize`

```ruby
# (lib/faraday/connection.rb)

def initialize(url = nil, options = nil)
  options = ConnectionOptions.from(options) # => ConnectionOptions

  if url.is_a?(Hash) || url.is_a?(ConnectionOptions)
    options = Utils.deep_merge(options, url)
    url     = options.url
  end

  @parallel_manager = nil
  @headers = Utils::Headers.new
  @params  = Utils::ParamsHash.new
  @options = options.request
  @ssl = options.ssl
  @default_parallel_manager = options.parallel_manager
  @manual_proxy = nil

  @builder = options.builder || begin
    # pass an empty block to Builder so it doesn't assume default middleware
    options.new_builder(block_given? ? proc { |b| } : nil)
  end

  self.url_prefix = url || 'http:/'

  @params.update(options.params)   if options.params
  @headers.update(options.headers) if options.headers

  initialize_proxy(url, options)

  yield(self) if block_given?

  @headers[:user_agent] ||= USER_AGENT
end

# ConnectionOptions (lib/faraday/options/connection_options.rb)

module Faraday
  ConnectionOptions = Options.new(
    :request, :proxy, :ssl, :builder, :url,
    :parallel_manager, :params, :headers,
    :builder_class
  ) do

    options request: RequestOptions, ssl: SSLOptions
    memoized(:request) { self.class.options_for(:request).new }
    memoized(:ssl) { self.class.options_for(:ssl).new }
    memoized(:builder_class) { RackBuilder }

    def new_builder(block)
      builder_class.new(&block)
    end
  end
end
```

## `Connection#get`

```ruby
# (lib/faraday/connection.rb)

class Connection
  # ...
  # Connection#get など (lib/faraday/connection.rb)
  METHODS_WITH_QUERY.each do |method| # => Connection#run_request
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def #{method}(url = nil, params = nil, headers = nil)
        run_request(:#{method}, url, nil, headers) do |request|
          request.params.update(params) if params
          yield request if block_given?
        end
      end
    RUBY
  end

  # ...
end

# Connection#run_request ((lib/faraday/connection.rb))

def run_request(method, url, body, headers)
  unless METHODS.include?(method)
    raise ArgumentError, "unknown http method: #{method}"
  end

  request = build_request(method) do |req|
    req.options.proxy = proxy_for_request(url)
    req.url(url)                if url
    req.headers.update(headers) if headers
    req.body = body             if body
    yield(req) if block_given?
  end

  builder.build_response(self, request)
end
```
