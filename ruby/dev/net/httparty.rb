require "httparty"

res = HTTParty.get("https://example.com/")

puts res.body
puts "---"
p res.class # HTTParty::Response
pp res.headers # HTTParty::Response::Headers
p res.code
p res.content_type
p res.headers["last-modified"]

# https://github.com/jnunemaker/httparty
# https://www.rubydoc.info/github/jnunemaker/httparty/HTTParty/
