require "httpclient"

client = HTTPClient.new
client.debug_dev = $stderr # デバッグ情報
response = client.get("http://example.com")

puts response.body
puts response.headers

# https://github.com/nahi/httpclient
# https://www.rubydoc.info/gems/httpclient/frames
