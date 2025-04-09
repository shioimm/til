require "httpi"

req = HTTPI::Request.new
req.url = "https://example.com"

res = HTTPI.get(req)

puts res.body
puts "---"
p res.class # HTTPI::Response
p res.code
p res.headers # HTTPI::Utils::Headers
p res.headers["Last-Modified"]

HTTPI.adapter = :httpclient
puts HTTPI.get(req).class

__END__
# https://github.com/savonrb/httpi/blob/main/lib/httpi.rb

def get(request, adapter = nil, &block)
  request = Request.new(request) if request.kind_of? String
  request(:get, request, adapter, &block)
end

def request(method, request, adapter = nil, redirects = 0)
  adapter_class = load_adapter(adapter, request)

  Adapter.client_setup_block.call(adapter_class.client) if Adapter.client_setup_block
  yield adapter_class.client if block_given?
  log_request(method, request, Adapter.identify(adapter_class.class))

  response = adapter_class.request(method)
  # 各アダプタに依存している

  if response && HTTPI::Response::RedirectResponseCodes.member?(response.code) && request.follow_redirect? && redirects < request.redirect_limit
    request.url = URI.join(request.url, response.headers['location'])
    log("Following redirect: '#{request.url}'.")
    return request(method, request, adapter, redirects + 1)
  end

  response
end
