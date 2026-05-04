# SVCBリソースレコード (SVCB Resource Record / SVCB RR)
- エンドツーエンドで通信を行う際の後続のプロトコルに関する情報提供を行うリソースレコード
  - HTTPSレコードはHTTP/HTTPS通信に特化したもの
  - SVCBレコードは任意のプロトコルで利用できるもの

### SvcParamKey
- SVCB / HTTPSレコードに記述されるサービスパラメータ群
  - alpn: 対応するアプリケーション層プロトコル (e.g. `h2=HTTP/2`、`h3=HTTP/3`)
  - no-default-alpn: デフォルトのプロトコルネゴシエーションを無効化する
  - port: 接続先ポート番号
  - ipv4hint: IPv4アドレスのヒント (DNS解決を省略するためのキャッシュ)
  - ipv6hint: IPv6アドレスのヒント
  - ech: ECH (Encrypted Client Hello) の公開鍵設定

### SVCB ServiceModeレコード
- DNSのリソースレコードで、対象になるドメインで利用する情報を事前に提供するもの
  - `ech`、`alpn`、`port`などのパラメータ (SvcParamKey) が含まれる
  - `ech`はECH (Encrypted Client Hello) を利用するために必要なサーバの公開鍵を格納する
- SVCB-reliant: ECHを利用するため、SVCBレコードの情報を必ず必要とするクライアント
- SVCB-optional: SVCBレコードがなくても接続できるが、あれば活用するクライアント

## 参照
- [Amazon Route 53の新しいHTTPS/SVCB/SSHFP/TLSAリソースレコードタイプについての技術概説とユースケースの考察](https://business.ntt-east.co.jp/content/cloudsolution/ih_column-154.html#section-2)
