require "httpi"

req = HTTPI::Request.new
req.url = "https://example.com"

res = HTTPI.get(req)

puts res.body
puts "---"
p res.class # HTTPI::Response
p res.code
p res.headers # HTTPI::Utils::Headers
p res.headers["Last-Modified"]

HTTPI.adapter = :httpclient
puts HTTPI.get(req).class
