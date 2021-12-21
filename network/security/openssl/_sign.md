# 自己署名
```
# CSR (fd.csr) を利用して自己署名証明書 (fd.crt) を生成する
$ openssl x509 -req -days 365 -in fd.csr -signkey fd.key -out fd.crt

# 鍵 (fd.key) のみを利用して自己署名証明書 (fd.crt) を生成する
$ openssl req -new -x509 -days 365 -key fd.key -out fd.crt
```

```
# 作成した証明書 (fd.crt) の構造をフォーマットして出力
$ openssl x509 -text -in fd.crt -noout
```

## 参照
- プロフェッショナルSSL/TLS
