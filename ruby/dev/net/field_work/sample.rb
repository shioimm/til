require "net/http"

uri = URI.parse("https://example.com/")

Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
  res = http.get("/")
  puts res.body
end

__END__

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
