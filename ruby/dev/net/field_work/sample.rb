require "net/http"

# uri = URI.parse("https://example.com/")
# res = Net::HTTP.get_response("www.example.com", "index.html")
# res = Net::HTTP.get_response(uri, { "Accept" => "text/html" })

uri = URI("https://httpbin.org/post")
data = '{ "foo": "bar" }'
res = Net::HTTP.post(uri, data, { "Content-Type": "application/json" })

p res
