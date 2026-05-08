# SVCBリソースレコード (SVCB Resource Record / SVCB RR) / HTTPSリソースレコード (HTTPS Resource Record / HTTPS RR)
- エンドツーエンドで通信を行う際の後続のプロトコルに関する情報提供を行うリソースレコード
  - HTTPSレコードはHTTP/HTTPS通信に特化したもの
  - SVCBレコードは任意のプロトコルで利用できるもの

```text
<owner name>  IN [SVCB | HTTPS]  <priority>  <TargetName>  <SvcParams>
```

```text
;; 利用しない
    example.com.  IN  A         ***.***.***.***
                  IN  AAAA      ***:***:***:***

;; HTTPSリソースレコードを利用する
    example.com.  IN  HTTPS  1  svr.example.com.
svr.example.com.  IN  A         ***.***.***.***
                  IN  AAAA      ***:***:***:***

;; HTTPSリソースレコードとA / AAAAレコードを併用する
    example.com.  IN  HTTPS  1  .
    example.com.  IN  A         ***.***.***.***
                  IN  AAAA      ***:***:***:***
```

### SvcParamKey
- SVCB / HTTPSレコードに記述されるサービスパラメータ群
  - alpn: 対応するアプリケーション層プロトコル (e.g. `h2=HTTP/2`、`h3=HTTP/3`)
  - no-default-alpn: デフォルトのプロトコルネゴシエーションを無効化する
  - port: 接続先ポート番号
  - ipv4hint: IPv4アドレスのヒント (DNS解決を省略するためのキャッシュ)
  - ipv6hint: IPv6アドレスのヒント
  - ech: ECH (Encrypted Client Hello) の公開鍵設定

### SVCB ServiceModeレコード
- 対象になるドメインで利用する情報を事前に提供するもの。レコード内に必要な情報を記述する
  - `ech`、`alpn`、`port`などのパラメータ (SvcParamKey) が含まれる
  - `ech`はECH (Encrypted Client Hello) を利用するために必要なサーバの公開鍵を格納する
- priorityは1以上 (priorityの小さい順に処理される)
- SVCB-reliant: ECHを利用するため、SVCBレコードの情報を必ず必要とするクライアント
- SVCB-optional: SVCBレコードがなくても接続できるが、あれば活用するクライアント

#### AliasMode
- 別のDNS名への代替を行うもの。レコード内にリダイレクトさせたいドメイン名を記述する
  - CNAMEレコードとの違いはZone Apex (DNSゾーンの最上位のドメイン名) の応答が可能になる点
- priorityは0

## 参照
- [“HTTPSレコード”って知ってる？今知るべき4つの注意点](https://eng-blog.iij.ad.jp/archives/12882)
- [Amazon Route 53の新しいHTTPS/SVCB/SSHFP/TLSAリソースレコードタイプについての技術概説とユースケースの考察](https://business.ntt-east.co.jp/content/cloudsolution/ih_column-154.html#section-2)
