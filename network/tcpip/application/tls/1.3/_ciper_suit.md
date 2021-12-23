# 暗号スイート

```
TLS_AES_128_GCM_SHA256

// AES - アルゴリズム
// 128 - 強度
// GCM - モード
// TLS_AES_128 - 暗号
// SHA256 - HKDFハッシュ
```

| 暗号スイート名                 | AEADアルゴリズム  | HKDFハッシュ | 用途                         |
| -                              | -                 | -            | -                            |
| `TLS_AES_128_GCM_SHA256`       | AES-128-CCM       | SHA256       | 一般的なコンピュータ         |
| `TLS_AES_128_CCM_8_SHA256`     | AES-256-CCM-8     | SHA256       | IoT用の端末など              |
| `TLS_AES_128_CCM_SHA256`       | AES-128-GCM       | SHA256       | IoT用の端末など              |
| `TLS_AES_256_GCM_SHA384`       | AES-256-GCM       | SHA384       | 安全性にバッファが必要な場合 |
| `TLS_CHACHA20_POLY1305_SHA256` | ChaCha20-Poly1305 | SHA256       | モバイル端末など             |

## 参照
- プロフェッショナルSSL/TLS
