require "excon"

res = Excon.get("https://example.com")
puts res.body
puts "---"
p res.class # Excon::Response
p res.headers # Excon::Headers
p res.headers["Last-Modified"]
p res.remote_ip
p res.status
