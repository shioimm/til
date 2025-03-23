require "net/http"

Net::HTTP.get_print "www.example.com", "/index.html"

uri = URI.parse("http://www.example.com/index.html")
response = Net::HTTP.get_response(uri)
p response.header

http = Net::HTTP.new("www.example.com", 80)
request = Net::HTTP::Get.new("/index.html")
response = http.request(request)
response.each_value { |k, v| p "#{k}: #{v}" }

uri = URI.parse("https://github.com/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = (uri.scheme == "https")
request = Net::HTTP::Get.new("/ruby")
response = http.request(request)
p response.fetch("server")
