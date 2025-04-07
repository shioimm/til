require "httparty"

res = HTTParty.get("https://example.com/")

puts res.body
puts "---"
p res.class # HTTParty::Response
pp res.headers # HTTParty::Response::Headers
p res.code
p res.content_type
p res.headers["last-modified"]

# https://github.com/jnunemaker/httparty
# https://www.rubydoc.info/github/jnunemaker/httparty/HTTParty/
__END__
# https://github.com/jnunemaker/httparty/blob/main/lib/httparty.rb

def get(path, options = {}, &block)
  perform_request Net::HTTP::Get, path, options, &block
end

def perform_request(http_method, path, options, &block) #:nodoc:
  build_request(http_method, path, options).perform(&block)
end

def build_request(http_method, path, options = {})
  options = ModuleInheritableAttributes.hash_deep_dup(default_options).merge(options)
  HeadersProcessor.new(headers, options).call
  process_cookies(options)
  Request.new(http_method, path, options)
end

# https://github.com/jnunemaker/httparty/blob/main/lib/httparty/request.rb

def perform(&block)
  validate
  setup_raw_request
  chunked_body = nil
  current_http = http

  begin
    self.last_response = current_http.request(@raw_request) do |http_response|
      if block
        chunks = []

        http_response.read_body do |fragment|
          encoded_fragment = encode_text(fragment, http_response['content-type'])
          chunks << encoded_fragment if !options[:stream_body]
          block.call ResponseFragment.new(encoded_fragment, http_response, current_http)
        end

        chunked_body = chunks.join
      end
    end

    handle_host_redirection if response_redirects?
    result = handle_unauthorized
    result ||= handle_response(chunked_body, &block)
    result
  rescue *COMMON_NETWORK_ERRORS => e
    raise options[:foul] ? HTTParty::NetworkError.new("#{e.class}: #{e.message}") : e
  end
end

def http
  connection_adapter.call(uri, options)
end

https://github.com/jnunemaker/httparty/blob/main/lib/httparty/connection_adapter.rb#L69

def self.call(uri, options)
  new(uri, options).connection
end

def connection
  host = clean_host(uri.host)
  port = uri.port || (uri.scheme == 'https' ? 443 : 80)
  if options.key?(:http_proxyaddr)
    http = Net::HTTP.new(
      host,
      port,
      options[:http_proxyaddr],
      options[:http_proxyport],
      options[:http_proxyuser],
      options[:http_proxypass]
    )
  else
    http = Net::HTTP.new(host, port)
  end

  http.use_ssl = ssl_implied?(uri)

  attach_ssl_certificates(http, options)

  if add_timeout?(options[:timeout])
    http.open_timeout = options[:timeout]
    http.read_timeout = options[:timeout]
    http.write_timeout = options[:timeout]
  end

  if add_timeout?(options[:read_timeout])
    http.read_timeout = options[:read_timeout]
  end

  if add_timeout?(options[:open_timeout])
    http.open_timeout = options[:open_timeout]
  end

  if add_timeout?(options[:write_timeout])
    http.write_timeout = options[:write_timeout]
  end

  if add_max_retries?(options[:max_retries])
    http.max_retries = options[:max_retries]
  end

  if options[:debug_output]
    http.set_debug_output(options[:debug_output])
  end

  if options[:ciphers]
    http.ciphers = options[:ciphers]
  end

  # Bind to a specific local address or port
  #
  # @see https://bugs.ruby-lang.org/issues/6617
  if options[:local_host]
    http.local_host = options[:local_host]
  end

  if options[:local_port]
    http.local_port = options[:local_port]
  end

  http
end
