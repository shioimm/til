# 事前共有鍵とセッションリザンプション
## 事前共有鍵 (PSK: Pre-Shared Key) による認証
- TLS1.3では (署名に利用する) 証明書以外にPSKでも認証が可能
  - PSKを利用する場合、証明書による認証は不要
  - セッションリザンプションで利用できる
- サーバーは証明書による認証でハンドシェイクに成功した場合、
  クライアントに対して1 つもしくは複数のPSKを発行可能
  - 以降の接続ではクライアントがそのPSKを使って認証する
- クライアントが1つもしくは複数のPSKを持っておりそれを利用したい場合、
  `psk_key_exchange_modes`拡張を使用してサーバーに意向を伝える

```c
struct {
    PskKeyExchangeMode ke_modes<1..255>;
} PskKeyExchangeModes;

enum { psk_ke(0), psk_dhe_ke(1), (255) } PskKeyExchangeMode;

// PskKeyExchangeMode:
//   psk_dhe_ke - PFS (完全前方秘匿性) が有効になるオプション
//   psk_ke - PFS (完全前方秘匿性) が有効にならないオプションpsk_ke
```

- 認証に必要な情報の転送に`pre_shared_key`拡張を使用する

```
struct {
  PskIdentity identities<7..2^16-1>;
  PskBinderEntry binders<33..2^16-1>; // PSKを所持していることを示す証明となるHMAC値
} OfferedPsks;

struct {
  opaque identity<1..2^16-1>;
  uint32 obfuscated_ticket_age; // クライアントから見たClientHelloの鮮度
} PskIdentity;

opaque PskBinderEntry<32..255>;
```

- PSKを用いた認証を行う場合サーバーはPSKのIDを選択し、ハンドシェイクを進める
- 接続およびハンドシェイクの完遂に使う鍵はサーバーが選択したPSKを使って通信の双方で生成する

## セッションリザンプション
- TLS1.3ではセッションリザンプションのために従来のセッションID方式とセッションチケット方式は廃止された
- PSKを使って相互認証を行いつつセッションの再開を行うことができる
- サーバはセッション中の New Session Ticket にてPSKを払い出し、
- セッションリザンプションに対応するサーバーはハンドシェイクが完了するまで待ち、
  NewSessionTicketメッセージにてPSKを払い出す

```
struct {
  uint32 ticket_lifetime; // チケットの寿命 (7日以内)
  uint32 ticket_age_add; // チケットの経過秒数への加算
  opaque ticket_nonce<0..255>; // PSKを計算する際に使用
  opaque ticket<1..2^16-1>; // チケット (値はサーバーの実装に応じて異なる)
  Extension extensions<0..2^16-2>; // チケットに対する拡張
} NewSessionTicket;
```

- 次回セッション再開時にクライアントはPSKによる認証を行いつつ、
  PSKを素にしたセッションリザンプションを行うことができる
- クライアントとサーバーはハンドシェイクでやり取りするメッセージとチケットの`ticket_nonce`と
  `resumption_master_secret`鍵を使用し、PSKを計算する

```
HKDF-Expand-Label(resumption_master_secret, "resumption", ticket_nonce, Hash.length)
```

- 一セッションはセッションキーを維持し続けるまでの時間 (RFCの仕様上は24時間)

#### 動作フロー (1-RTT)
1. クライアント -> サーバー
    - ClientHello [`pre_shared_key`]
2. クライアント <- サーバー
    - ServerHello
    - 鍵共有で生成した共通鍵でネゴシエーションの途中から通信を暗号化

#### 動作フロー (0-RTT)
1. クライアント -> サーバー
    - ClientHello [`pre_shared_key`, `early_data`]
2. クライアント <- サーバー
    - 暗号化されたアプリケーションデータ

## 参照
- プロフェッショナルSSL/TLS
- [TLS v1.3の仕組み ~Handshakeシーケンス,暗号スイートをパケットキャプチャで覗いてみる~](https://milestone-of-se.nesuke.com/nw-basic/tls/tls-version-1-3/)
