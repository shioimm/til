require "net/http"

require "net/http"
require "openssl"

uri = URI("https://example.com")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

res = http.get("/")
puts res.body

# uri = URI("https://httpbin.org/post")
# data = '{ "foo": "bar" }'
# res = Net::HTTP.post(uri, data, { "Content-Type": "application/json" })
#
# p res
