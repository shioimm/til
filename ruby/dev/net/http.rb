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
