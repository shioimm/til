# DoT (DNS over TLS) / DoH (DNS over HTTPS) / DoQ (DNS over QUIC)
- 平文のDNSトラフィックを暗号化するための規格

## DoT (DNS over TLS)
- DNSクエリをTCP上でTLSを利用して送信することで暗号化する
- 専用ポート853を使用する

## DoH (DNS over HTTPS)
- DNSクエリをHTTPSリクエストとして送信することで暗号化する
- HTTPSのポート443を使用する

## DoQ (DNS over QUIC)
- DNSクエリをQUICで送信することで暗号化する

## 参照
- [DoH/DoT入門](https://www.nic.ad.jp/ja/materials/iw/2019/proceedings/d3/d3-yamaguchi.pdf)
