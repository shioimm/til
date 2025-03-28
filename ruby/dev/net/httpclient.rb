require "httpclient"

client = HTTPClient.new
client.debug_dev = $stderr # デバッグ情報
res = client.get("http://example.com")

puts res.body
puts("---")

p res.class # HTTP::Message
p res.status
pp res.headers # Hash
p res.content_type
p res.headers["Last-Modified"]

# https://github.com/nahi/httpclient
# https://www.rubydoc.info/gems/httpclient/frames
