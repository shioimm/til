# 事前共有鍵とセッションリザンプション
## 事前共有鍵による認証
- TLS1.3では (署名に利用する) 証明書以外に事前共有鍵 (pre-shared keys) でも認証が可能
  - 事前共有鍵を利用する場合、証明書による認証は不要
  - セッションリザンプションで利用できる
- サーバーは証明書による認証でハンドシェイクに成功した場合、
  クライアントに対して1 つもしくは複数の事前共有鍵を発行可能
  - 以降の接続ではクライアントがその事前共有鍵を使って認証する
- クライアントが1つもしくは複数の事前共有鍵を持っておりそれを利用したい場合、
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
  PskBinderEntry binders<33..2^16-1>; // 事前共有鍵を所持していることを示す証明となるHMAC値
} OfferedPsks;

struct {
  opaque identity<1..2^16-1>;
  uint32 obfuscated_ticket_age; // クライアントから見たClientHelloの鮮度
} PskIdentity;

opaque PskBinderEntry<32..255>;
```

- 事前共有鍵を用いた認証を行う場合サーバーは事前共有鍵のIDを選択し、ハンドシェイクを進める
- 接続およびハンドシェイクの完遂に使う鍵はサーバーが選択した事前共有鍵を使って通信の双方で生成する

## セッションリザンプション
- 事前共有鍵を使ってセッションリザンプションを行うことができる
- セッションリザンプションに対応するサーバーはハンドシェイクが完了するまで待ち、
  NewSessionTicketメッセージにてチケットを送信する

```
struct {
  uint32 ticket_lifetime; // チケットの寿命 (7日以内)
  uint32 ticket_age_add; // チケットの経過秒数への加算
  opaque ticket_nonce<0..255>; // 事前共有鍵を計算する際に使用
  opaque ticket<1..2^16-1>; // チケット (値はサーバーの実装に応じて異なる)
  Extension extensions<0..2^16-2>; // チケットに対する拡張
} NewSessionTicket;
```

- クライアントとサーバーはハンドシェイクでやり取りするメッセージとチケットの`ticket_nonce`と
  `resumption_master_secret`鍵を使用し、事前共有鍵を計算する

```
HKDF-Expand-Label(resumption_master_secret, "resumption", ticket_nonce, Hash.length)
```

## 参照
- プロフェッショナルSSL/TLS
