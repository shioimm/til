# Network Namespace
- 参照: Linuxで動かしながら学ぶTCP/IPネットワーク入門 3.1
- ネットワーク的にホスト環境から独立した領域

```
# 新規Namespaceを作成
$ sudo ip netns add NAMESPACE

# Network Namespace一覧を出力
$ ip netns list

# Network Namespaceでコマンドを実行
$ sudo ip netns exec NAMESPACE COMMAND

# Network Namespaceでシェルを起動
$ sudo ip netns exec NAMESPACE bash

# Network Namespaceを削除する
$ sudo ip netns delete NAMESPACE # またはシステムのシャットダウン
```

## 同一セグメント上でのネットワーク接続
- Network Namespace同士を同一ネットワークセグメント上で接続する
1. 新規Namespaceを2つ作成する
2. veth(Virtual Ethernet Device)ペアを作成する
    - vethは2つの仮想的なネットワークインターフェースの組み
    - 片方のインターフェースにパケットが届くともう片方からパケットが出てくる
3. 各vethをNetwork Namespace内にセットする
4. 各vethにIPアドレスを付与する
5. 各vethを有効化する

```
# ネットワークインターフェース(vethペア)の作成
$ sudo ip link add VETHNAME1-veth0 type veth peer name VETHNAME2-veth0

# 作成したネットワークインターフェースの確認
$ ip link show | grep veth
3: VETHNAME2-veth0@VETHNAME1-veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
4: VETHNAME1-veth0@VETHNAME2-veth0: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000

# 各Network Namespace内に各vethをセット
$ sudo ip link set VETHNAME1-veth0 netns NAMESPACE1
$ sudo ip link set VETHNAME2-veth0 netns NAMESPACE2

# ネットワークインターフェースが各Network Namespace内にセットされているか確認
$ sudo ip netns exec NAMESPACE1 ip link show | grep veth
3: VETHNAME1-veth0@if3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
$ sudo ip netns exec NAMESPACE2 ip link show | grep veth
4: VETHNAME2-veth0@if4: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000

# Network Namespace内にセットしたvethペアはホスト上から見えなくなる
$ ip link show | grep veth # => 何も表示されない

# ネットワークインターフェースにIPアドレスを設定する
$ sudo ip netns exec NAMESPACE1 ip address add ADDRESS1/PREFIXLENGTH dev VETHNAME1-veth0
$ sudo ip netns exec NAMESPACE2 ip address add ADDRESS2/PREFIXLENGTH dev VETHNAME2-veth0

# ネットワークインターフェースの現在の設定を表示
# sudo ip netns exec NAMESPACE1 ip link show VETHNAME1-veth0
# sudo ip netns exec NAMESPACE2 ip link show VETHNAME2-veth0

# ネットワークインターフェースを有効化する
#   UP=有効 / DOWN=無効(初期値)
$ sudo ip netns exec NAMESPACE1 ip link set VETHNAME1-veth0 up
$ sudo ip netns exec NAMESPACE2 ip link set VETHNAME2-veth0 up

# 疎通確認
$ sudo ip netns exec NAMESPACE1 ping ADDRESS2
```

## 異なるセグメント間でのネットワーク接続
- Network Namespace同士をネットワークセグメントをまたいで接続する
WIP
