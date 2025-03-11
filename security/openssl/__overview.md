# OpenSSL
```
$ openssl version -a

# OPENSSLDIR - OpenSSLが設定と証明書を探す場所
```

#### フォーマット
- 作成する秘密鍵と証明書は様々なフォーマットに格納が可能 (一般的にはPEM)
  - バイナリ形式 (DER) の証明書
    - X.509 証明書をそのままの形式 (DER ASN.1 エンコーディング) で含む
  - ASCII形式 (PEM) の証明書
    - base64でエンコードされたDER形式の証明書
  - PKCS#7形式の証明書
    - 署名されたデータや暗号化されたデータを転送するために設計された複合的な形式 (.p7b / .p7c)
  - バイナリ(DER)形式の鍵
    - 秘密鍵をそのままの形式 (DER ASN.1 エンコーディング) で含む
  - ASCII形式 (PEM) の鍵
    - base64 でエンコードされたDER形式の鍵
  - PKCS#12 (PFX) 形式の鍵と証明書
    - サーバの鍵を証明書チェーン全体と一緒に格納して保護できる形式 (.pfx)

```
# PEM -> DER: 証明書を変換
$ openssl x509 -inform PEM -in fd.pem -outform DER -out fd.der

# DER -> PEM: 証明書を変換
$ openssl x509 -inform DER -in fd.der -outform PEM -out fd.pem
```

## 参照
- [OpenSSL](https:#www.openssl.org/)
- プロフェッショナルSSL/TLS
