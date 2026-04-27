# Happy Eyeballs Version 3 (HEv3)
- https://datatracker.ietf.org/doc/draft-ietf-happy-happyeyeballs-v3/
- https://datatracker.ietf.org/wg/happy/documents/
- Lazy Eye Inspection: Capturing the State of Happy Eyeballs Implementations
- QUIC通信を優先する Happy Eyeballs Version 3 の提案
  - https://asnokaze.hatenablog.com/entry/2023/10/26/014349

## Overviews
1. 非同期DNSクエリの開始
    - HTTPS / AAAA / AいずれかのDNSレスポンスを受け取った場合、
      AAAAとHTTPSを両方受信する、あるいは`ipv6hint`をもつHTTPSを受信するまで
      一定時間待機した後、次のステップに進む
2. 解決された宛先アドレスのソート
    - HTTPSレコードから得られたECHやQUICサポート情報を優先的に並べる
    - IPファミリ / プロトコルをインタリーブさせて、リストを作成する
      - QUIC IPv6
      - TCP IPv6
      - QUIC IPv4
      - TCP IPv4
3. 非同期接続試行の開始
    - リストに従って、順番に接続試行を開始
4. 1つの接続を確立し、他のすべての試行をキャンセルする
    - TCPの場合: TCPハンドシェイクの完了
    - QUICの場合; QUICハンドシェイク完了

## 構成要素
- DNS / 拡張DNS
  - SVCB and HTTPS Resource Records
    - https://datatracker.ietf.org/doc/html/rfc9460
  - DNS64: DNS Extensions for Network Address Translation from IPv6 Clients to IPv4 Servers
     - https://datatracker.ietf.org/doc/html/rfc6147
  - IPv6 Addressing of IPv4/IPv6 Translators
    - https://datatracker.ietf.org/doc/html/rfc6052
- アドレス選択
  - Default Address Selection for Internet Protocol Version 6 (IPv6)
    - https://datatracker.ietf.org/doc/html/rfc6724
- TLS (ALPN, ECH)
  - Transport Layer Security (TLS) Application-Layer Protocol Negotiation Extension
    - https://datatracker.ietf.org/doc/html/rfc7301
  - Encrypted Client Hello
    - https://blog.cloudflare.com/ja-jp/announcing-encrypted-client-hello/
  - Encrypted ClientHelloの仕組み
    - https://eng-blog.iij.ad.jp/archives/32414
- QUIC
  - QUIC: A UDP-Based Multiplexed and Secure Transport
    - https://datatracker.ietf.org/doc/html/rfc9000
- HTTP/3
  - HTTP/3
    - https://datatracker.ietf.org/doc/html/rfc9114
