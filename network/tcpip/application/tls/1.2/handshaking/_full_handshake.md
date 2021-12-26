# フルハンドシェイク
1. クライアント -> サーバー
    - SYN
2. クライアント <- サーバー
    - ACK + SYN
3. クライアント -> サーバー
    - ACK
4. クライアント -> サーバー
    - ClientHello
5. クライアント <- サーバー
    - ServerHello
    - Certificate
    - CertificateRequest (optional)
    - ServerKeyExchange (optional)
    - ServerHelloDone
6. クライアント -> サーバー
    - Certificate (optional)
    - ClientKeyExchange
    - CertificateVerify (optional)
    - ChangeCipherSpec
    - Finished
7. クライアント <- サーバー
    - ChangeCipherSpec
    - Finished
8. アプリケーションデータプロトコルへ移行
    - アプリケーションデータをMAC鍵でハッシュ化、セッション鍵で暗号化してアプリケーションレコードで転送
6. Alertによって`close_notify`の発生を通信相手に通知する
7. AlertによってSSL/TLSの終了を伝え、SSL/TLSセッションを終了する

#### ClientHello (クライアント)
- 使用できるバージョン番号、現在時刻、クライアントランダム、
  セッションID (初期値はNULL)、
  使用できる暗号スイート一覧、使用できる圧縮方法一覧を送信
- ClientHelloは新規にコネクションを開始するとき、再ネゴシエーションするとき、
  サーバーからの再ネゴシエーションの要求 (HelloRequest) に応えるときに送信される

#### ServerHello (サーバー)
- 使用するバージョン番号、現在時刻、サーバーランダム、
  セッションID (サーバーが生成した値)、
  使用する暗号スイート、使用する圧縮方法を送信

#### Certificate (サーバー)
- X.509証明書チェーンを送信 (X.509証明書以外の形式でも可)
  - チェーンの先頭はサーバー証明書、その次に中間証明書、末尾にルート証明書
  - ルート証明書は不要であるため省くべき
- クライアントはX.509証明書チェーンを検証する

#### CertificateRequest (サーバー: optional)
- クライアント認証を行う場合、サーバーが理解できる証明書のタイプ・認証局の名前一覧を送信

```c
struct {
  ClientCertificateType certificate_types;
  SignatureAndHashAlgorithm supported_signature_algorithms;
  DistinguishedName certificate_authorities;
} CertificateRequest;
```

#### ServerKeyExchange (サーバー: optional)
- 鍵交換のためのメッセージ
- 使用する暗号スイートの内容によって必要な場合、追加の情報を送信 (鍵交換)

#### Certificate (クライアント: optional)
- クライアント認証を行う場合、証明書を送信
- サーバーは証明書を検証する

#### ClientKeyExchange (クライアント)
- 鍵交換のためのメッセージ
- 暗号スイートがRSAを用いる場合、暗号化したプリマスターシークレット (乱数) を送信
- 暗号スイートがDH鍵交換を用いる場合、Diffie-Hellman公開値を送信
- サーバーとクライアントはプリマスターシークレットを用いてマスターシークレットを計算
- サーバーとクライアントマスターシークレットを用いて共通鍵暗号の鍵・MACの鍵・初期化ベクトルの一部を作成

#### CertificateVerify (クライアント: optional)
- クライアント認証を行う場合、クライアント証明書の秘密鍵を持っていることを通知

```c
struct {
  Signature handshake_messages_signature;
} CertificateVerify;
```

#### Finished (サーバー・クライアント)
- メッセージは暗号化されており、ネゴシエーション済みのMACによって真正性が保証されている
- クライアントとサーバのそれぞれが受信したハンドシェイクメッセージのすべてをハッシュ化し、
  その値とマスターシークレットを組み合わせて計算したデータ (`verify_data`フィールド) を含む

```
verify_data = PRF(master_secret, finished_label, Hash(handshake_messages))

// PRF - 疑似乱数生成器
// finished_label - クライアント: client finished / サーバー: server finished
// Hash - PRFで定義されているものと同じハッシュ関数
```

#### `verify_data`
- クライアントとサーバがそれぞれ受信したハンドシェイクメッセージのすべてをハッシュ化したもの、
  `finished_label` (クライアントは`client finished`、サーバーは`server finished`)、
  マスターシークレットを組み合わせて擬似乱数生成器にかけて計算した12バイトの値
- サーバー・クライアントの`verify_data`が一致すると
  アプリケーションデータの暗号化通信を開始することができる

```
verify_data = PRF(master_secret, finished_label, Hash(handshake_messages))
```

## 参照
- プロフェッショナルSSL/TLS
- 暗号技術入門 第3版
- パケットキャプチャの教科書
- [TLS v1.3の仕組み ~Handshakeシーケンス,暗号スイートをパケットキャプチャで覗いてみる~](https://milestone-of-se.nesuke.com/nw-basic/tls/tls-version-1-3/)
