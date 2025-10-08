require "httpx"

HOST = "https://example.com"

response = HTTPX.get(HOST)

puts "--- HEADERS ---"
response.headers.each { |k, v| puts "#{k}: #{v}" }

puts "--- BODY ---"
puts response.body

p response
