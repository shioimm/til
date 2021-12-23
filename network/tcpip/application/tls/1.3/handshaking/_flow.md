# フロー
1. クライアント -> サーバー
    - SYN
2. クライアント <- サーバー
    - ACK + SYN
3. クライアント -> サーバー
    - ACK
    - ClientHello
4. クライアント <- サーバー
    - ServerHello
    - EncryptedExtensions
    - Certificate
    - CertificateVerify
    - Finished
    - アプリケーションデータ
5. クライアント -> サーバー
    - Finished
    - アプリケーションデータ

#### ClientHello (クライアント)
- DH鍵共有のための秘密鍵情報 (KS: Key Share) 、事前鍵共有 (PSK: Pre Shared Key) を送信 (optional)
- クライアントから1つもしくは複数の異なる鍵交換の手法を提案し、
  鍵交換アルゴリズムに必要なパラメータをすべてサーバに送信する
  - TLS1.2でClientHelloの後、サーバーが鍵交換の種類を選択していた

```c
uint16 ProtocolVersion;
opaque Random[32];
uint8 CipherSuite[2];    // Cryptographic suite selector

struct {
  ProtocolVersion legacy_version = 0x0303;    // TLS v1.2
  Random random; // 32バイトの暗号学的にランダムなデータを格納
  opaque legacy_session_id<0..32>;
  CipherSuite cipher_suites<2..2^16-2>;
  opaque legacy_compression_methods<1..2^8-1>;
  Extension extensions<8..2^16-1>;
} ClientHello;
```

#### ServerHello (サーバー)
- クライアントから提案された接続のためのパラメータに合意できればServerHelloメッセージで応答
- DH鍵共有のための秘密鍵情報 (KS: Key Share) 、事前鍵共有 (PSK: Pre Shared Key) を送信
- 秘密鍵の共有が完了し移行暗号化通信へ移行

```c
struct {
  ProtocolVersion legacy_version = 0x0303;    // TLS v1.2
  Random random;
  opaque legacy_session_id_echo<0..32>;
  CipherSuite cipher_suite;
  uint8 legacy_compression_method = 0;
  Extension extensions<6..2^16-1>;
} ServerHello;
```

#### HelloRetryRequest (サーバー)
- クライアントから提案された鍵交換アルゴリズムに対応できなかった場合、
  ハンドシェイクが失敗した旨をクライアントに伝える

#### EncryptedExtensions (サーバー)
- サーバー拡張の利用
- 暗号化したサーバーパラメータを送信

#### Certificate (サーバー)
- 暗号化したサーバー証明書を送信

#### アプリケーションデータ (サーバー・クライアント)
- 認証処理が終わり次第暗号化されたアプリケーションデータを送信

#### Finished (サーバー・クライアント)
- 暗号化されたFinishedメッセージを送信

## 参照
- プロフェッショナルSSL/TLS
- 暗号技術入門 第3版
- パケットキャプチャの教科書
