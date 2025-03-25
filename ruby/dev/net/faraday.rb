require "faraday"

connection = Faraday.new(url: "http://example.com")
response = connection.get "/index.html"
p response.headers
puts response.body

connection = Faraday.new(url: "https://github.com")
response = connection.get "/ruby"
p response.headers
puts response.body

# ref https://nekorails.hatenablog.com/entry/2018/09/28/152745
