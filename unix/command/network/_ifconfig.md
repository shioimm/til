# ifconfig(1)
- 自身のプライベートIPアドレスを表示する
- 古いコマンドのためLinuxでは代わりにip(1) (iproute2パッケージから提供) を使用する

```
$ ifconfig

en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
  inet 192.168.1.100 netmask 0xffffff00 broadcast 192.168.1.255
  ether xx:xx:xx:xx:xx:xx
```

- en0: インターフェース名
- flags: インターフェイスの現在の状態や機能を示すフラグ
  - `UP` - インターフェースが有効
  - `BROADCAST` - ブロードキャストアドレスをサポート
  - `SMART` - 特定のスマート機能が有効 (macOS)
  - `RUNNING` - インターフェイスが動作中 (リンクが確立)
  - `SIMPLEX` - パケットがループバックされない (送信元パケットが戻らない)
  - `MULTICAST` - マルチキャストをサポート
- mtu: MTU
- inet: このインターフェイスに割り当てられたIPv4アドレス
- netmask: サブネットマスク (16進数)
  - 0xffffff00 - 255.255.255.0
- broadcast: このインターフェイスが属するネットワークのブロードキャストアドレス
- ether: このインターフェイスのMACアドレス

### インターフェース名
- anpi1 - Apple Network Private Interface
  - macOSやiOS特有のプライベートネットワーク関連の仮想インターフェース
- ap1 - アクセスポイントインターフェース
  - ホストがアクセスポイントとして動作する際に使用される
- awdl0 - Apple Wireless Direct Link
  - Apple独自のP2P無線通信プロトコルを使用するインターフェース
- bridge0 - ブリッジインターフェース
  - 複数のネットワークインターフェースを1つの仮想ネットワーク内に結合するためのインターフェース
    - 仮想マシンのネットワーク
    - 複数のネットワーク間の通信の中継
- en0 - Ethernetインターフェース
- gif0 - Generic Interface
  - トンネル用の仮想インターフェース
  - IPv6-over-IPv4 や IPv4-over-IPv6 トンネリングに使用される
- llw0 - Low Latency Wireless Interface
  - Appleの低遅延ワイヤレスプロトコルを使用するインターフェース
- lo0 - ループバックインターフェース
- stf0 - 6to4 トンネルインターフェース
  - IPv6トラフィックをIPv4 ネットワーク上で送信するために使用される仮想インターフェース (現在はほとんど使用されない)
- utun0 - トンネルインターフェース
  - 主にVPN接続で使用される仮想インターフェース

## 参照
- [Ubuntu 17.04 その132 - ifconfigからipコマンドへ移行しよう・ipコマンドはifconfigを置き換える](https://kledgeb.blogspot.com/2017/07/ubuntu-1704-132-ifconfigipipifconfig.html)
