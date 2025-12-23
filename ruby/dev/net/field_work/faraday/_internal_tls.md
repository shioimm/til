# faraday 現地調査: TLS編 (202512時点)

## HTTPSを利用する
- httpsスキームを指定する

```ruby
conn = Faraday.new("https://example.com")
res  = conn.get("/")
puts res.body
```

- 明示的に設定を制御する

```ruby
conn = Faraday.new("https://example.com") { |f|
  f.ssl.verify = true # OpenSSL::SSL:VERIFY_PEER
  f.ssl.ca_file = "/etc/ssl/certs/ca-certificates.crt"
  f.ssl.ca_path = "/etc/ssl/certs"
  f.ssl.client_cert = OpenSSL::X509::Certificate.new(File.read("client.crt"))
  f.ssl.client_key  = OpenSSL::PKey::RSA.new(File.read("client.key"))
  f.ssl.min_version = :TLS1_2
  f.ssl.max_version = :TLS1_3
  f.ssl.ciphers = "TLS_AES_128_GCM_SHA256"
}

res  = conn.get("/")
puts res.body
```
