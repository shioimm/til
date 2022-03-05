# 同一セグメント上でのネットワーク接続
- Network Namespace同士を同一ネットワークセグメント上で接続する

---

1. ホストNamespaceを2つ作成する
2. veth(Virtual Ethernet Device)ペアを作成する
    - vethは2つの仮想的なネットワークインターフェースの組み
    - 片方のインターフェースにパケットが届くともう片方からパケットが出てくる
3. 各vethをNetwork Namespace内にセットする
4. 各vethにIPアドレスを付与する
5. 各vethを有効化する

```
-----
HOST1
-----
  | HOST1-veth0
  |
  | HOST2-veth0
-----
HOST2
-----
```

```
# 新規Namespaceを作成
$ sudo ip netns add HOST1
$ sudo ip netns add HOST2

# ネットワークインターフェース(vethペア)の作成
$ sudo ip link add HOST1-veth0 type veth peer name HOST2-veth0

# 作成したネットワークインターフェースの確認
$ ip link show | grep veth
3: HOST2-veth0@HOST1-veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
4: HOST1-veth0@HOST2-veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000

# 各Network Namespace内に各vethをセット
$ sudo ip link set HOST1-veth0 netns HOST1
$ sudo ip link set HOST2-veth0 netns HOST2

# ネットワークインターフェースが各Network Namespace内にセットされているか確認
$ sudo ip netns exec HOST1 ip link show | grep veth
3: HOST1-veth0@if3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
$ sudo ip netns exec HOST2 ip link show | grep veth
4: HOST2-veth0@if4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000

# Network Namespace内にセットしたvethペアはホスト上から見えなくなる
$ ip link show | grep veth # => 何も表示されない

# ネットワークインターフェースにIPアドレスを設定する
$ sudo ip netns exec HOST1 ip address add HOST1_ADDRESS/PREFIXLE dev HOST1-veth0
$ sudo ip netns exec HOST2 ip address add HOST2_ADDRESS/PREFIXLE dev HOST2-veth0

# ネットワークインターフェースの現在の設定を表示
# sudo ip netns exec HOST1 ip link show HOST1-veth0
# sudo ip netns exec HOST2 ip link show HOST2-veth0

# ネットワークインターフェースを有効化する
#   UP=有効 / DOWN=無効(初期値)
$ sudo ip netns exec HOST1 ip link set HOST1-veth0 up
$ sudo ip netns exec HOST2 ip link set HOST2-veth0 up

# 疎通確認
$ sudo ip netns exec HOST1 ping HOST2_ADDRESS
```

## 参照
- Linuxで動かしながら学ぶTCP/IPネットワーク入門
