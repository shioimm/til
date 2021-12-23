# TLS1.3
- TLS1.3ではTLSレコードのペイロードを保護して機密性と完全性を同時に確保するため、
  認証付き暗号 (AEAD) を利用する

```
// パラメータとしてnonce、平文、暗号化不要な付加的なデータ (完全性の検証のために含める)
AEADEncrypted = AEAD-Encrypt(write_key, nonce, plaintext, additional_data)

// nonceの生成のために通信の双方でそれぞれ保持している64ビット長のメッセージカウンタを利用する
// additional_data = TLSCiphertext.opaque_type || TLSCiphertext.legacy_record_version || TLSCiphertext.length
```

- TLS1.3では平文の長さは暗号化される

## 参照
- プロフェッショナルSSL/TLS
