# CSR (Certificate Signing Request) 作成
```
# CSR (fd.csr) の作成
$ openssl req -new -days 3650 -sha256 -key fd.key > fd.csr

# CSR (fd.csr) の再確認
$ openssl req -text -in fd.csr -noout
```

```
# 既存の証明書 (fd.crt) から鍵 (fd.key) を用いてCSR (fd.csr) を生成する
$ openssl x509 -x509toreq -in fd.crt -out fd.csr -signkey fd.key
```

## 参照
- プロフェッショナルSSL/TLS
