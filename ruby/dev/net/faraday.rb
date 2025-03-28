require "faraday"

client = Faraday.new(url: "http://example.com")
res = client.get "/index.html"
puts res.body
puts("---")
p client.class # Faraday::Connection
p res.class # Faraday::Response
p res.status
pp res.headers # Faraday::Utils::Headers
p res.headers["content-type"]
p res.headers["last-modified"]

# ref https://nekorails.hatenablog.com/entry/2018/09/28/152745
