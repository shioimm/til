# net-http 現地調査: TLS編 (202512時点)

## HTTPSを利用する

- `use_ssl`オプションを渡す

```ruby
uri = URI.parse("https://example.com/")

Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
  res = http.get("/")
  puts res.body
end
```

```ruby
uri = URI("https://example.com")

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

res = http.get("/")
puts res.body
```
