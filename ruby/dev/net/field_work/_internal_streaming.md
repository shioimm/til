# net-http 現地調査 (net-http-0.9.1時点)

以下の条件を満たすと例外が発生

- `HTTP::Response#read_body`にブロックを渡す
- `HTTP::Response#body_encoding=`を呼び出す

```ruby
uri = URI.parse("http://google.com")
http = Net::HTTP.new(uri.host, uri.port)
req = Net::HTTP::Get.new(uri)

http.request(req) do |response|
  # レスポンスのサイズが大きい or 不明なのでチャンクで読み取りたい
  # かつ最終的な結果も欲しい
  # かつテキストとして正しく扱いたい (nokogiriに渡したいなど) 場合など

  response.body_encoding = true
  body = +""
  response.read_body { |chunk| body << chunk }

  # => HTTP::Response#read_bodyのブロックを抜ける際に例外が発生する
  # undefined method 'force_encoding' for an instance of Net::ReadAdapter (NoMethodError)
end
```

```ruby
# この場合は発生しない
res = http.request(req)
res.body_encoding = true
res.body
```
