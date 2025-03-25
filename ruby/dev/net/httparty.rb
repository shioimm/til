require "httparty"

response = HTTParty.get("http://example.com")

puts response.body
p response.headers

response = HTTParty.get("https://github.com/ruby")

puts response.body
p response.headers

# ref: https://www.rubydoc.info/github/jnunemaker/httparty/HTTParty/ClassMethods
