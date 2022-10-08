# 鍵交換
- ServerKeyExchange (optional) とClientKeyExchangeによって
  クライアント - サーバー間で共有するマスターシークレットの素材となる
  プリマスターシークレットの生成に必要なパラメータの交換を行う

```c
struct {
  select (KeyExchangeAlgorithm) {
    case dh_anon:
        ServerDHParams   params;
    case dhe_rsa:
        ServerDHParams   params;
        Signature        params_signature;
    case ecdh_anon:
        ServerECDHParams params;
    case ecdhe_rsa:
    case ecdhe_ecdsa:
        ServerECDHParams params;
      Signature
    case rsa:
    case dh_rsa:
  };
} ServerKeyExchange

// アルゴリズムによってはパラメータが不要
```

```c
struct {
  select (KeyExchangeAlgorithm) {
    case rsa:
      EncryptedPreMasterSecret;
    case dhe_dss:
    case dhe_rsa:
    case dh_dss:
    case dh_rsa:
    case dh_anon:
      ClientDiffieHellmanPublic;
    case ecdhe:
      ClientECDiffieHellmanPublic;
  } exchange_keys;
} ClientKeyExchange;
```

## 参照
- プロフェッショナルSSL/TLS
- 暗号技術入門 第3版
- パケットキャプチャの教科書
- [TLS v1.3の仕組み ~Handshakeシーケンス,暗号スイートをパケットキャプチャで覗いてみる~](https://milestone-of-se.nesuke.com/nw-basic/tls/tls-version-1-3/)
