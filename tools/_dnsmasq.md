# dnsmasq
- 小規模ネットワーク向けのDNSフルリゾルバとDHCPサーバを兼ねたソフトウェア
- LinuxなどのUNIX系OSで動作する
- ルータなどに組み込まれて提供されることが多い

## 関連する設定ファイル
- `/etc/dnsmasq.conf`
  - DNS設定とDHCP設定をそれぞれ記述

```
# DNS設定
# port=5353                            ポート番号
# domain=local                         ローカルドメイン名
# addn-hosts=/etc/hosts-dnsmasq        hostsとして参照させたいファイルを指定
# resolv-file=/etc/dnsmasq_resolv.conf 上位DNSの設定ファイル
# log-facility=/var/log/dnsmasq.log    ログの出力先

# no-hosts      デフォルトの/etc/hostsを参照したくない場合
# domain-needed 上位サーバへ問い合わせる際は、ドメイン名が必須
# bogus-priv    上位サーバに対してプライベートIPアドレスの逆引き要求をしない
# expand-hosts  ドメイン名を自動的にhostsに付与する場合
# log-queries   DNSクエリのログを取る場合
# dnssec        DNSSECバリデーションを有効化する場合

# DHCP設定
# interface=ens224 DNS, dhcpを提供するNICを指定
# no-dhcp-interface=eth0 dhcpを提供しないNICを指定
# dhcp-option=option:router,192.168.10.1 デフォルトゲートウェイ
```
