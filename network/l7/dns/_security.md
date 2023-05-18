# DNS関連のセキュリティ事項
## Do53
- 平文のDNSプロトコル (53/udp・53/tcpポートを使用)

## DNSSEC (DNS Security extensions)
- 権威DNSサーバーが返す値に署名を付与したもの
- DNSキャッシュサーバーへのキャッシュポイズニング攻撃を防ぐために導入
- DNSキャッシュサーバーは署名を検証することによりキャッシュポイズニング攻撃を防御する

#### DANE (DNS-Based Authentication of Named Entities)
- DNSSECとTLSの認証との橋渡しをするDNS拡張
- ドメイン名とそのドメインに対して発行された証明書との紐づけを、DNS を使って行うための標準
- DANEを活用するとパブリックCAを完全に迂回することもできる
  - 信頼できるNDSであればDNSをTLSの認証に使えるようになる

## DoT (DNS-over-TLS) (RFC7858)
- TCP上でTLSを用いて通信を暗号化する
- クライアントとキャッシュDNSサーバー間の通信に秘匿性・完全性を持たせるために導入
- 通信時にポート番号853を利用する

## DoD (DNS-over-DTLS) (RFC8094)
- UDP上でDTLS (TLSをUDPに適用する規格) を用いて通信を暗号化する

## DoH (DNS-over-HTTPS) (RFC8484)
- DNSのリクエストレスポンスをHTTPS上で行う
- クライアントとキャッシュDNSサーバー間の通信に秘匿性・完全性を持たせるために導入
- 通信時にポート番号443を利用する
- HoLブロッキングの問題を回避するため、主にHTTP/2、HTTP/3が利用される

## Split-horizon DNS
- DNS実装において、DNSリクエストを行ったソースアドレスによって異なるDNS回答を返す機能

## 参照
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書
- プロフェッショナルSSL/TLS
- [Split-horizon DNS](https://en.wikipedia.org/wiki/Split-horizon_DNS)
