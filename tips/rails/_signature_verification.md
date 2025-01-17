# 署名の検証

```ruby
body = '{"message": "Hi"}'
secret = "my-secret-key"

digest    = OpenSSL::Digest.new("sha256") # SHA256ハッシュアルゴリズムを指定
hmac      = OpenSSL::HMAC.digest(digest, secret, body) # HMACを計算
signature = Base64.strict_encode64(hmac) # HMACの結果のバイナリデータをBase64エンコードし、可読な形式に変換

ActiveSupport::SecurityUtils.secure_compare("検証したい署名", signature)
```
