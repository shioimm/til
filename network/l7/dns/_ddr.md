# DDR (Discovery of Designated Resolvers)
- DNSリゾルバがDoHに対応していることを自動的に検出してアップグレードする仕組み
  - DHCPは端末に対してDNSリゾルバのIPアドレスを優先順に返す
  - 端末はそれらのIPアドレスがDoHやDoTなどの暗号化プロトコルに対応しているDNSリゾルバのものであるかを
    順に検証する
- PKIで検証したTLS証明書によって暗号化DNSリゾルバを認証することで安全性を担保する

## 参照
- [RubyKaigiとDNS-over-HTTPSとDDR](https://blog.kmc.gr.jp/entry/2023/05/10/165300)
- [draft-ietf-add-ddr](https://datatracker.ietf.org/doc/draft-ietf-add-ddr/)
