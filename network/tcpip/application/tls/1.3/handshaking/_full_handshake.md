# フロー
1. クライアント -> サーバー
    - SYN
2. クライアント <- サーバー
    - ACK + SYN
3. クライアント -> サーバー
    - ACK
    - ClientHello [`key_share`]
4. クライアント <- サーバー
    - ServerHello [`key_share`]
    - EncryptedExtensions
    - Certificate
    - CertificateVerify
    - Finished
    - アプリケーションデータ
5. クライアント -> サーバー
    - Finished
    - アプリケーションデータ

#### ClientHello (クライアント)
- クライアントは`supported_groups`拡張を利用して1つもしくは複数の異なる鍵交換の手法を提案する
  - TLS1.2でClientHelloの後、サーバーが鍵交換の種類を選択していた
- クライアントは`key_share`拡張を利用して鍵交換アルゴリズムに必要なパラメータをすべて送信可能
  - パラメータ: DH鍵共有のための秘密鍵情報 (KS: Key Share) 、事前鍵共有 (PSK: Pre Shared Key)
  - `key_share`拡張はTLS1.2のClientKeyExchangeと同じ

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
- クライアントから提案された鍵交換方式に合意できればServerHelloメッセージで応答
- `key_share`拡張を利用して鍵交換アルゴリズムに必要なパラメータをすべて送信可能
  - パラメータ: DH鍵共有のための秘密鍵情報 (KS: Key Share) 、事前鍵共有 (PSK: Pre Shared Key)
  - `key_share`拡張はTLS1.2のServerKeyExchangeと同じ
- 秘密鍵の共有が完了し暗号化通信へ移行
- クライアントが提案した選択肢に合意できない場合、
  `supported_groups`拡張を利用して1つもしくは複数の異なる鍵交換の手法を提案する

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
- クライアントから提案された鍵交換方式に対応できなかった場合、
  ハンドシェイクが失敗した旨をクライアントに伝える

#### EncryptedExtensions (サーバー)
- サーバー拡張の利用
- 暗号化したサーバーパラメータを送信

#### CertificateRequest (サーバー)
- クライアント認証の要求

```c
struct {
  opaque certificate_request_context<0..2^8-1>; // 特定の証明書を要求することを一意に特定する
  Extension extensions<2..2^16-1>;
} CertificateRequest;
```

#### Certificate (サーバー・クライアント(オプショナル))
- 暗号化した証明書を送信
- 複数の証明書を格納することも可能
- 個々の証明書に対して任意の拡張を付与することが可能
  - OCSPの失効情報、SCTなど

```c
enum {
  X509(0),
  RawPublicKey(2),
  (255)
} CertificateType;

struct {
  select (certificate_type) {
    case RawPublicKey:
      opaque ASN1_subjectPublicKeyInfo<1..2^24-1>; // From RFC 7250 ASN.1_subjectPublicKeyInfo
    case X509:
      opaque cert_data<1..2^24-1>;
  };
  Extension extensions<0..2^16-1>;
} CertificateEntry;

struct {
  opaque certificate_request_context<0..2^8-1>;
  CertificateEntry certificate_list<0..2^24-1>;
} Certificate;
```

#### CertificateVerify (サーバー・クライアント(オプショナル))
- ハンドシェイクで送信済の証明書に対する秘密鍵を持っていることを証明する

```c
struct {
  SignatureScheme algorithm; // 署名アルゴリズムについての指示
  opaque signature<0..2^16-1>; // デジタル署名: ハンドシェイクと証明書を関連付けるもの
} CertificateVerify;

// signature:
//   64個のスペース (0x20) からなる文字列
//   + 署名の目的を表す文字列 ('TLS 1.3, server CertificateVerify' || 'TLS 1.3, client CertificateVerify')
//   + 1バイトのゼロ (0x00)
//   + トランスクリプトハッシュ
// に署名したもの
```

#### アプリケーションデータ (サーバー・クライアント)
- 認証処理が終わり次第、暗号化されたアプリケーションデータを送信

#### Finished (サーバー・クライアント)
- 暗号化されたFinishedメッセージを送信
- ハンドシェイクの完全性を検証するため、クライアントとサーバーは
  それぞれ交換したデータに対する署名を送信する

```c
struct {
  opaque verify_data[Hash.length]; // トランスクリプトハッシュから計算したHMAC値
} Finished;
```

```
verify_data = HMAC(finished_key, Transcript-Hash(Handshake Context, Certificate*, CertificateVerify*))
```

#### Post-Handshake Authentication (クライアント)
- ハンドシェイク後の認証に対応しているクライアントは`post_handshake_auth`拡張にて
  サーバーにその旨を伝える
- サーバーは最初のハンドシェイクを完了した後の任意の段階でCertificateRequestメッセージを送信し、
  クライアントに対して認証を求めることができる

## 参照
- プロフェッショナルSSL/TLS
- 暗号技術入門 第3版
- パケットキャプチャの教科書
- [TLS v1.3の仕組み ~Handshakeシーケンス,暗号スイートをパケットキャプチャで覗いてみる~](https://milestone-of-se.nesuke.com/nw-basic/tls/tls-version-1-3/)
