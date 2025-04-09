require "httpclient"

client = HTTPClient.new
client.debug_dev = $stderr # デバッグ情報
res = client.get("http://example.com")

puts res.body
puts("---")

p res.class # HTTP::Message
p res.status
pp res.headers # Hash
p res.content_type
p res.headers["Last-Modified"]

# https://github.com/nahi/httpclient
# https://www.rubydoc.info/gems/httpclient/frames
__END__
# https://github.com/nahi/httpclient/blob/master/lib/httpclient.rb

def get(uri, *args, &block)
  request(:get, uri, argument_to_hash(args, :query, :header, :follow_redirect), &block)
end

def request(method, uri, *args, &block)
  query, body, header, follow_redirect = keyword_argument(args, :query, :body, :header, :follow_redirect)
  if method == :propfind
    header ||= PROPFIND_DEFAULT_EXTHEADER
  else
    header ||= {}
  end
  uri = to_resource_url(uri)
  if block
    filtered_block = adapt_block(&block)
  end
  if follow_redirect
    follow_redirect(method, uri, query, body, header, &block)
  else
    do_request(method, uri, query, body, header, &filtered_block)
  end
end

def do_request(method, uri, query, body, header, &block)
  res = nil
  if HTTP::Message.file?(body)
    pos = body.pos rescue nil
  end
  retry_count = @session_manager.protocol_retry_count
  proxy = no_proxy?(uri) ? nil : @proxy
  previous_request = previous_response = nil
  while retry_count > 0
    body.pos = pos if pos
    req = create_request(method, uri, query, body, header)
    if previous_request
      # to remember IO positions to read
      req.http_body.positions = previous_request.http_body.positions
    end
    begin
      protect_keep_alive_disconnected do
        # TODO: remove Connection.new
        # We want to delete Connection usage in do_get_block but Newrelic gem depends on it.
        # https://github.com/newrelic/rpm/blob/master/lib/new_relic/agent/instrumentation/httpclient.rb#L34-L36
        conn = Connection.new
        res = do_get_block(req, proxy, conn, &block)
        # Webmock's do_get_block returns ConditionVariable
        if !res.respond_to?(:previous)
          res = conn.pop
        end
      end
      res.previous = previous_response
      break
    rescue RetryableResponse => e
      previous_request = req
      previous_response = res = e.res
      retry_count -= 1
    end
  end
  res
end

def do_get_block(req, proxy, conn, &block)
  @request_filter.each do |filter|
    filter.filter_request(req)
  end
  if str = @test_loopback_response.shift
    dump_dummy_request_response(req.http_body.dump, str) if @debug_dev
    res = HTTP::Message.new_response(str, req.header)
    conn.push(res)
    return res
  end
  content = block ? nil : ''.dup
  res = HTTP::Message.new_response(content, req.header)
  @debug_dev << "= Request\n\n" if @debug_dev
  sess = @session_manager.query(req, proxy)
  res.peer_cert = sess.ssl_peer_cert
  @debug_dev << "\n\n= Response\n\n" if @debug_dev
  do_get_header(req, res, sess)
  conn.push(res)
  sess.get_body do |part|
    set_encoding(part, res.body_encoding)
    if block
      block.call(res, part.dup)
    else
      content << part
    end
  end
  # there could be a race condition but it's OK to cache unreusable
  # connection because we do retry for that case.
  @session_manager.keep(sess) unless sess.closed?
  commands = @request_filter.collect { |filter|
    filter.filter_response(req, res)
  }
  if commands.find { |command| command == :retry }
    raise RetryableResponse.new(res)
  end
  res
end
