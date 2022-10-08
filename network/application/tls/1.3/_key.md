# 暗号鍵の導出
- 暗号鍵はハンドシェイクの段階で生成される
- 鍵の導出は特定の鍵導出関数 (KDF: key derivation function)として実装される

#### 鍵導出関数 HKDF (HMAC-based Key Derivation Function)
- TLS1.3で新たに設計された鍵導出関数
- 短いシードや補助入力から秘密鍵として利用できる複数の安全な疑似乱数を取得する
- 抽出 (extraction) と伸張 (expansion) の工程を経て鍵を生成する

```
// 抽出 - 入力から利用可能なエントロピーを取り出す工程。強力な疑似乱数の鍵を1つ生成する
HKDF-Extract(salt, input) -> extracted_key // saltはオプション

// 伸張 - 抽出の出力から任意の長さの疑似乱数の鍵を任意の個数導出する工程
HKDF-Expand(extracted_key, context, length) -> expanded_key // contextは複数の鍵が必要な場合に使用
```

## 参照
- プロフェッショナルSSL/TLS
- 暗号技術入門 第3版
