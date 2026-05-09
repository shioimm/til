# DNSSEC (Domain Name System Security Extensions)
- DNSキャッシュポイズニングのような攻撃を防ぐため、公開鍵暗号方式と電子署名の仕組みを応用し、
  DNSに対してデータ作成元の認証やデータの完全性の検証を行うことができるようにするための仕様拡張
  - DNSキャッシュサーバが権威サーバから取得したDNS応答が
    「問い合わせた本来の権威サーバからの応答かどうか」
    「パケット内容が改ざんされていないかどうか」
    「問い合わせたレコードが存在するか否か」を検証する
- 通信の暗号化は行わない

## 処理の流れ

```text
ゾーン管理者                        権威ネームサーバ           フルリゾルバ
    |                                       |                          |
    | * 秘密鍵と公開鍵の鍵ペアを作成        |                          |
    | * ゾーン内のRRsetの電子署名を作成     |                          |
    |                                       |                          |
    |--- 電子署名 (RRSIGレコード) を登録 -->|                          |
    |--- 公開鍵 (DNSKEYレコード) を登録 --->|                          |
    |                                       |                          |
    |                                       |<--- DNS問い合わせ -------|
    |                                       |                          |
    |                                       |---- DNS応答------------->|
    |                                       |     * RRset              |
    |                                       |     * RRSIG              |
    |                                       |     * DNSKEY             |
    |                                       |                          |
    |                                       |                          | DNS応答をゾーン管理者による公開鍵で検証
```

1. [権威サーバのゾーン管理者] DNSSECのための準備
    - 秘密鍵と公開鍵の鍵ペアを作成する
    - ゾーン内のリソースレコードセット (RRset) のデータをハッシュ化し、そのハッシュ値を秘密鍵で暗号化する (電子署名)
    - 作成した電子署名をRRSIGレコードとして権威ネームサーバに登録する
    - 公開鍵をDNSKEYレコードとして権威ネームサーバに登録する
2. [フルリゾルバ] 権威サーバ宛にDNS問い合わせ
3. [権威サーバ] フルリゾルバ宛にRRset、電子署名 (RRSIGレコード)、公開鍵 (DNSKEYレコード) を返す
4. [フルリゾルバ] 権威サーバから受信した応答をゾーン管理者による公開鍵で検証
    - `RRsetをハッシュ化した値 ==  RRSIGレコード中の電子署名をDNSKEYレコードの公開鍵で復号した値`の場合、
      そのメッセージは該当ゾーンの管理者が作成し、改竄もされていない

## DNSSECで追加されたリソースレコード
### DNSKEY
- ゾーンを署名する秘密鍵に対応する公開鍵

```text
<owner name>  <TTL>  IN  DNSKEY  <Flags>  <Protocol>  <Algorithm>  <Public Key>
```

- Flags: 鍵の用途と性質を示す16bitの値
  - 256: ZSK (Zone Signing Key) ゾーンに署名するゾーン署名鍵
  - 257: KSK (Key Signing Key) ゾーン署名鍵ZSKに署名する鍵署名鍵
- Protocol: 常に3
- Algorithm: 公開鍵アルゴリズムを示す識別子
  - 8: RSA/SHA-256
  - 13: ECDSA P-256 / SHA-256
  - 15: Ed25519
- Public Key: Base64 エンコードされた公開鍵データ

```text
example.com.  300  IN  DNSKEY  257  3  13 ...
```

### RRSIG
- リソースレコードの電子署名

```text
<owner name>  <TTL>  IN  RRSIG  (
  <Type Covered>
  <Algorithm>
  <Labels>
  <Original TTL>
  <Signature Expiration>
  <Signature Inception>
  <Key Tag>
  <Signer's Name>
  <Signature>
)
```

- Type Covered: この署名が対象とするRRsetのタイプ
- Algorithm: 署名に使用した暗号アルゴリズムの識別子 (DNSKEYのAlgorithmと同じ値)
- Labels: 署名対象のowner nameのラベル数 (ワイルドカード処理に使用)
- Original TTL: 署名対象RRsetの権威ゾーンにおけるTTL
- Signature Expiration: 署名の有効期限 (YYYYMMDDHHmmSS)
- Signature Inception: 署名の有効開始日時 (YYYYMMDDHHmmSS)
- Key Tag: 署名検証に使うDNSKEYを識別するための短い数値
- Signer's Name: 署名検証に使うDNSKEYのowner name
- Signature: Base64エンコードされた電子署名データ

```text
example.com.  300  IN  RRSIG  (
  A  13  2  300  20260601000000  20260509000000  12345  example.com.
  ...
)
```

### DS
- 親ゾーンに登録され、子ゾーンのKSK (DNSKEY Flags=257) のハッシュ値を保持するレコード
- フルリゾルバはこのレコードを使って親ゾーンから子ゾーンへの信頼の連鎖を検証する

```text
<owner name>  <TTL>  IN  DS  <Key Tag>  <Algorithm>  <Digest Type>  <Digest>
```

- Key Tag: 参照先のDNSKEYを識別するための短い数値 (RRSIGのKey Tagと同じ算出方法)
- Algorithm: 参照先のDNSKEYのアルゴリズム識別子
- Digest Type: ダイジェスト生成に使用したアルゴリズムの識別子
  - 1: SHA-1
  - 2: SHA-256
  - 4: SHA-384
- Digest: 参照先のDNSKEYをハッシュ化した値

```text
example.com.  300  IN  DS  12345  13  2  ABC123DEF456...
```

### NSEC
- 存在していないゾーンについて問い合わせがあった場合、
  そのゾーンを管理する権威ネームサーバが、不存在との旨の回答に署名するためのリソースレコード
- そのゾーン名がわからないようにハッシュ関数で計算されたハッシュ値によりゾーンを示すのはNSEC3レコード

```text
<owner name>  <TTL>  IN  NSEC  <Next Domain Name>  <Type Bit Maps>
```

- Next Domain Name: ゾーン内で正規順序における次のowner name
- Type Bit Maps: このowner nameに存在するRRタイプのビットマップ

```text
a.example.com.  300  IN  NSEC  host.example.com.  A MX RRSIG NSEC
```

## 参照
- [DNSSEC](https://www.nic.ad.jp/ja/newsletter/No43/0800.html)
