# ベンチマーク
```
# 暗号アルゴリズムごとのベンチマークをとる
$ openssl speed rc4 aes rsa ecdh sha

# OpenSSL のバージョン番号とコンパイル時の設定、
# 共通鍵暗号化方式およびハッシュ関数のベンチマーク、
# 公開鍵暗号化方式のベンチマークが表示される

# 並列実行
$ openssl speed -multi 4 rsa
```

## 参照
- [OpenSSL](https:#www.openssl.org/)
- プロフェッショナルSSL/TLS
