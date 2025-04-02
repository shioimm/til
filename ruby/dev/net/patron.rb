require "patron"

session = Patron::Session.new
session.base_url = "http://example.com"
response = session.get("/index.html")
puts response.body
puts "---"

p response # #<Patron::Response @status_line='HTTP/1.1 200 OK'>
p response.status
p response.headers # Hash
p response.headers["Last-Modified"]

p session
# #<Patron::Session:0x000000011f53be00
#   @headers={"User-Agent" => "Patron/Ruby-0.13.4-libcurl/8.1.2 (SecureTransport) LibreSSL/3.3.6 zlib/1.2.11 nghttp2/1.51.0"},
#   @timeout=5,
#   @connect_timeout=1,
#   @max_redirects=5,
#   @auth_type=:basic,
#   @force_ipv4=false,
#   @base_url="http://example.com"
# >
