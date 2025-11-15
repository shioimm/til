require "net/http"

uri = URI.parse("https://example.com/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = (uri.scheme == "https")

req = Net::HTTP::Get.new("/index.html")
res = http.request(req)
puts res.body
puts("---")

p http.class # Net::HTTP
p res.class # Net::HTTPOK
p res.header # #<Net::HTTPOK 200 OK readbody=true>
res.each_key { p it }
p res["Last-Modified"]

p Net::HTTP.get("example.com", "/index.html", 80) # => String
p Net::HTTP.get(uri) # => String

p Net::HTTP.get_response(uri, { "Accept" => "text/html" }) # => Net::HTTPOK

uri = URI("https://httpbin.org/post")
data = '{ "foo": "bar" }'
p Net::HTTP.post(uri, data, { "Content-Type": "application/json" }) # => #<Net::HTTPOK 200 OK readbody=true>
