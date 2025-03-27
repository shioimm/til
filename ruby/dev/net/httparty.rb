require "httparty"

response = HTTParty.get("http://example.com")

puts response.body
p response.headers

response = HTTParty.get("https://github.com/ruby")

puts response.body
p response.headers

# https://github.com/jnunemaker/httparty
# https://www.rubydoc.info/github/jnunemaker/httparty/HTTParty/
