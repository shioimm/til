# ビルド
```
# ダウンロード
$ curl https:#www.openssl.org/source/openssl-*.*.*.tar.gz

# 設定処理
$ ./config  --prefix=/opt/openssl \
            --openssldir=/opt/openssl \
            enable-ec_nistp_64_gcc_128 # パラメータ

# ビルド
$ make depend
$ make

# インストール (/opt/openssl以下にインストールされる)
$ sudo make install

# 秘密鍵は/opt/openssl/private/以下に格納
# ルート証明書は/opt/openssl/certs/以下に格納
#   (OpenSSLにはトラストストア: 信頼できるルート証明書の一が含まれていないため空の状態)
#   (別途トラストストアを用意する必要がる)
```

## 参照
- [OpenSSL](https:#www.openssl.org/)
- プロフェッショナルSSL/TLS
