require "http"

res = HTTP.get('https://example.com')
puts res.body
puts("---")
p res
# #<HTTP::Response/1.1 200 OK
#   {
#     "Content-Type" => "text/html",
#     "ETag" => "\"84238dfc8092e5d9c0dac8ef93371a07:1736799080.121134\"",
#     "Last-Modified" => "Mon, 13 Jan 2025 20:11:20 GMT",
#     "Cache-Control" => "max-age=694",
#     "Date" => "Fri, 28 Mar 2025 22:40:53 GMT",
#     "Alt-Svc" => "h3=\":443\"; ma=93600,h3-29=\":443\"; ma=93600,quic=\":443\"; ma=93600; v=\"43\"",
#     "Content-Length" => "1256",
#     "Connection" => "close"
#   }
# >
p res.headers # HTTP::Headers
p res.headers["Last-Modified"]

__END__
$ gem i http
Fetching ffi-compiler-1.3.2.gem
Fetching llhttp-ffi-0.5.1.gem
Fetching http-form_data-2.3.0.gem
Fetching http-5.2.0.gem
Successfully installed ffi-compiler-1.3.2
Building native extensions. This could take a while...
Successfully installed llhttp-ffi-0.5.1
Successfully installed http-form_data-2.3.0
Successfully installed http-5.2.0
Parsing documentation for ffi-compiler-1.3.2
Installing ri documentation for ffi-compiler-1.3.2
Parsing documentation for llhttp-ffi-0.5.1
Installing ri documentation for llhttp-ffi-0.5.1
Parsing documentation for http-form_data-2.3.0
Installing ri documentation for http-form_data-2.3.0
Parsing documentation for http-5.2.0
Installing ri documentation for http-5.2.0
Done installing documentation for ffi-compiler, llhttp-ffi, http-form_data, http after 0 seconds
4 gems installed

--------------------------

# https://github.com/httprb/http/blob/main/lib/http/chainable.rb

def get(uri, options = {})
  request :get, uri, options
end

def request(*args)
  branch(default_options).request(*args)
end

tps://github.com/httprb/http/blob/main/lib/http/client.rb#L15

def request(verb, uri, opts = {})
  opts = @default_options.merge(opts)
  req = build_request(verb, uri, opts)
  res = perform(req, opts)
  return res unless opts.follow

  Redirector.new(opts.follow).perform(req, res) do |request|
    perform(wrap_request(request, opts), opts)
  end
end

def perform(req, options)
  verify_connection!(req.uri)

  @state = :dirty

  begin
    @connection ||= HTTP::Connection.new(req, options)

    unless @connection.failed_proxy_connect?
      @connection.send_request(req)
      @connection.read_headers!
    end
  rescue Error => e
    options.features.each_value do |feature|
      feature.on_error(req, e)
    end
    raise
  end
  res = build_response(req, options)

  res = options.features.values.reverse.inject(res) do |response, feature|
    feature.wrap_response(response)
  end

  @connection.finish_response if req.verb == :head
  @state = :clean

  res
rescue
  close
  raise
end

# https://github.com/httprb/http/blob/main/lib/http/connection.rb

def initialize(req, options)
  @persistent           = options.persistent?
  @keep_alive_timeout   = options.keep_alive_timeout.to_f
  @pending_request      = false
  @pending_response     = false
  @failed_proxy_connect = false
  @buffer               = "".b

  @parser = Response::Parser.new

  @socket = options.timeout_class.new(options.timeout_options)
  @socket.connect(options.socket_class, req.socket_host, req.socket_port, options.nodelay)

  send_proxy_connect_request(req)
  start_tls(req, options)
  reset_timer
rescue IOError, SocketError, SystemCallError => e
  raise ConnectionError, "failed to connect: #{e}", e.backtrace
rescue TimeoutError
  close
  raise
end
