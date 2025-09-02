require "faraday"

client = Faraday.new(url: "http://example.com")
res = client.get "/index.html"
puts res.body
puts("---")
p client.class # Faraday::Connection
p res.class # Faraday::Response
p res.status
pp res.headers # Faraday::Utils::Headers
p res.headers["content-type"]
p res.headers["last-modified"]

# ref https://nekorails.hatenablog.com/entry/2018/09/28/152745
__END__
# https://github.com/lostisland/faraday/blob/main/lib/faraday.rb
# https://github.com/lostisland/faraday/blob/1551c32371b42acd22c3d8c87bcbd19872624d5a/lib/faraday.rb
def new(url = nil, options = {}, &block)
  options = Utils.deep_merge(default_connection_options, options)
  Faraday::Connection.new(url, options, &block)
end

# https://github.com/lostisland/faraday/blob/1551c32371b42acd22c3d8c87bcbd19872624d5a/lib/faraday/connection.rb
METHODS_WITH_QUERY.each do |method|
  class_eval <<-RUBY, __FILE__, __LINE__ + 1
    def #{method}(url = nil, params = nil, headers = nil)
      run_request(:#{method}, url, nil, headers) do |request|
        request.params.update(params) if params
        yield request if block_given?
      end
    end
  RUBY
end

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

def build_request(method)
  Request.create(method) do |req|
    req.params  = params.dup
    req.headers = headers.dup
    req.options = options.dup
    yield(req) if block_given?
  end
end
