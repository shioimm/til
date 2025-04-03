require "curb"

res = Curl.get("https://example.com/")
puts res.body
puts "---"

p res # #<Curl::Easy https://example.com/>
p res.head # String
# "HTTP/2 200 \r\ncontent-type: text/html\r\netag: \"84238dfc8092e5d9c0dac8ef93371a07:1736799080.121134\"\r\nlast-modified: Mon, 13 Jan 2025 20:11:20 GMT\r\ncache-control: max-age=2416\r\ndate: Mon, 31 Mar 2025 00:37:44 GMT\r\nalt-svc: h3=\":443\"; ma=93600,h3-29=\":443\"; ma=93600,quic=\":443\"; ma=93600; v=\"43\"\r\ncontent-length: 1256\r\n\r\n"
p res.code

http = Curl::Easy.new("https://example.com/")
p http # #<Curl::Easy https://example.com/>
http.perform
p http.code
p http.method(:code).source_location

__END__
# https://github.com/taf2/curb/blob/master/lib/curl.rb

def self.get(url, params={}, &block)
  http :GET, urlalize(url, params), nil, nil, &block
end

def self.http(verb, url, post_body=nil, put_data=nil, &block)
  if Thread.current[:curb_curl_yielding]
    handle = Curl::Easy.new # we can't reuse this
  else
    handle = Thread.current[:curb_curl] ||= Curl::Easy.new
    handle.reset
  end

  handle.url = url
  handle.post_body = post_body if post_body
  handle.put_data = put_data if put_data

  if block_given?
    Thread.current[:curb_curl_yielding] = true
    yield handle
    Thread.current[:curb_curl_yielding] = false
  end

  handle.http(verb)
  handle
end
