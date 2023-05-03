# DHCP
```
# サーバープロセスにDHCP機能を付与する
$ sudo dnsmasq --dhcp-range=取り扱うIPアドレスの範囲 \
               --interface=ネットワークインターフェース \
               --port 0 \
               --no-resolv \
               --no-daemon

# DHCPサーバーへ問い合わせる
$ sudo dhclient -d ネットワークインターフェース
```
