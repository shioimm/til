require "faraday"

connection = Faraday.new(url: "http://example.com")
res = connection.get "/index.html"
puts res.body
puts("---")
p res.class
p res.status
pp res.headers
p res.headers["content-type"]
p res.headers["last-modified"]

# ref https://nekorails.hatenablog.com/entry/2018/09/28/152745
