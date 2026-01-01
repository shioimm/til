# httparty 現地調査: TLS編 (202512時点)
## HTTPSを利用する
- httpsスキームを指定する

```ruby
res = HTTParty.get("https://example.com/")
p res.body
```

- 明示的に設定を制御する

```ruby
store = OpenSSL::X509::Store.new
store.set_default_paths

HTTParty.get(
  "https://example.com",
  verify: true,
  ssl_ca_file: "/etc/ssl/certs/ca-certificates.crt",
  ssl_ca_path: "/etc/ssl/certs",
  # 中間証明書はクライアント証明書に結合した状態でssl_client_certに渡す
  ssl_client_cert: OpenSSL::X509::Certificate.new(File.read("client.crt")),
  ssl_client_key: OpenSSL::PKey::RSA.new(File.read("client.key")),
  cert_store: store,
  ssl_version: :TLSv1_2,
  ssl_min_version: :TLS1_2,
  ssl_max_version: :TLS1_3,
  ssl_ciphers: "TLS_AES_128_GCM_SHA256",
)

p res.body
```

- 初期設定を保存する

```ruby
class MyClient
  include HTTParty

  base_uri "https://example.com"

  verify true
  ssl_ca_file "/etc/ssl/certs/ca-certificates.crt"
  ssl_ca_path "/etc/ssl/certs"
  ssl_client_cert OpenSSL::X509::Certificate.new(File.read("client.crt"))
  ssl_client_key OpenSSL::PKey::RSA.new(File.read("client.key"))

  store = OpenSSL::X509::Store.new
  store.set_default_paths
  cert_store store

  ssl_version :TLSv1_2
  ssl_min_version :TLS1_2
  ssl_max_version :TLS1_3
  ssl_ciphers "TLS_AES_128_GCM_SHA256"
end

MyClient.get("/")
```
