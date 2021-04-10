# Network Namespace
- 参照: Linuxで動かしながら学ぶTCP/IPネットワーク入門
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

## 異なるセグメント間でのネットワーク接続
- Network Namespace同士をネットワークセグメントをまたいで接続する
1. ホストNamespaceとルーターNamespaceを作成する
2. veth(Virtual Ethernet Device)ペアを2つ作成する
3. 各vethをNetwork Namespace内にセットする
4. 各vethにIPアドレスを付与する
5. 各vethを有効化する
6. 各ホストNamespaceのルーティングテーブルにデフォルトルートを追加する
7. `sysctl`の`net.ipv4.ip_forward`パラメータを有効化
    - `net.ipv4.ip_forward` - ホストマシンをIPv4ルーターとして動作させる

```
-----
HOST1
-----
  | HOST1-veth0
  |
  | ROUTER-veth0
-----
ROUTER
-----
  | ROUTER-veth1
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
$ sudo ip netns add ROUTER

# ネットワークインターフェース(vethペア)の作成
$ sudo ip link add HOST1-veth0 type veth peer name ROUTER-veth0
$ sudo ip link add HOST2-veth0 type veth peer name ROUTER-veth1

# 各Network Namespace内に各vethをセット
$ sudo ip link set HOST1-veth0  netns HOST1
$ sudo ip link set ROUTER-veth0 netns ROUTER
$ sudo ip link set HOST2-veth0  netns HOST2
$ sudo ip link set ROUTER-veth1 netns ROUTER

# ネットワークインターフェースにIPアドレスを設定する
$ sudo ip netns exec HOST1 ip  address add NETWORK1_HOST_ADDRESS/PREFIXLEN   dev HOST1-veth0
$ sudo ip netns exec ROUTER ip address add NETWORK1_ROUTER_ADDRESS/PREFIXLEN dev ROUTER-veth0
$ sudo ip netns exec HOST2 ip  address add NETWORK2_HOST_ADDRESS/PREFIXLEN   dev HOST2-veth0
$ sudo ip netns exec ROUTER ip address add NETWORK2_ROUTER_ADDRESS/PREFIXLEN dev ROUTER-veth1

# ネットワークインターフェースを有効化する
#   UP=有効 / DOWN=無効(初期値)
$ sudo ip netns exec HOST1  ip link set HOST1-veth0  up
$ sudo ip netns exec ROUTER ip link set ROUTER-veth0 up
$ sudo ip netns exec HOST2  ip link set HOST2-veth0  up
$ sudo ip netns exec ROUTER ip link set ROUTER-veth1 up

# ルーティングテーブルにデフォルトルートを追加
$ sudo ip netns exec HOST1 ip route add default via NETWORK1_ROUTER_ADDRESS
$ sudo ip netns exec HOST2 ip route add default via NETWORK2_ROUTER_ADDRESS

# sysctlのnet.ipv4.ip_forwardパラメータを有効化
$ sudo ip netns exec ROUTER sysctl net.ipv4.ip_forward=1

# 疎通確認
$ sudo ip netns exec HOST1 ping NETWORK2_HOST_ADDRESS -I NETWORK1_HOST_ADDRESS
```

## ネットワークインターフェースのMACアドレス変更
- デフォルトではランダムなMACアドレスがvethインターフェースに割り振られる

```
$ sudo ip netns exec NAMESPACE ip link set dev VETHNAME-veth0 address MACADDRESS

# アドレスの確認
$ sudo ip netns exec NAMESPACE ip link show | grep link/ether

# MACアドレスのキャッシュを削除する
$ sudo ip netns exec NAMESPACE ip neigh flush all
```

## ネットワークブリッジを使用したネットワーク接続
- Network Namespace同士をネットワークブリッジを介して続する
1. ホストNamespaceとブリッジNamespaceを作成する
2. veth(Virtual Ethernet Device)ペアを3つ作成する
3. 各vethをNetwork Namespace内にセットする
4. ホスト側の各vethにIPアドレスを付与する
5. 各vethを有効化する
6. ブリッジNamespace内にネットワークブリッジを作成し、有効化する

```
-----
HOST1
-----
  | HOST1-veth0
  |
  | HOST1-br0
------                             -----
BRIDGE HOST3-br0 ----- HOST3-veth0 HOST3
------                             -----
  | HOST2-br0
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
$ sudo ip netns add HOST3
$ sudo ip netns add BRIDGE

# ネットワークインターフェース(vethペア)の作成
$ sudo ip link add HOST1-veth0 type veth peer name HOST1-br0
$ sudo ip link add HOST2-veth0 type veth peer name HOST2-br0
$ sudo ip link add HOST3-veth0 type veth peer name HOST3-br0

# 各Network Namespace内に各vethをセット
$ sudo ip link set HOST1-veth0 netns HOST1
$ sudo ip link set HOST2-veth0 netns HOST2
$ sudo ip link set HOST3-veth0 netns HOST3
$ sudo ip link set HOST1-br0   netns BRIDGE
$ sudo ip link set HOST2-br0   netns BRIDGE
$ sudo ip link set HOST3-br0   netns BRIDGE

# ネットワークインターフェースにIPアドレスを設定する
$ sudo ip netns exec HOST1 ip address add HOST1_ADDRESS/PREFIXLEN dev HOST1-veth0
$ sudo ip netns exec HOST2 ip address add HOST2_ADDRESS/PREFIXLEN dev HOST2-veth0
$ sudo ip netns exec HOST3 ip address add HOST3_ADDRESS/PREFIXLEN dev HOST2-veth0

# ネットワークインターフェースを有効化する
#   UP=有効 / DOWN=無効(初期値)
$ sudo ip netns exec HOST1  ip link set HOST1-veth0 up
$ sudo ip netns exec HOST2  ip link set HOST2-veth0 up
$ sudo ip netns exec HOST3  ip link set HOST3-veth0 up
$ sudo ip netns exec BRIDGE ip link set HOST1-br0   up
$ sudo ip netns exec BRIDGE ip link set HOST2-br0   up
$ sudo ip netns exec BRIDGE ip link set HOST3-br0   up

# ブリッジNamespace内にネットワークブリッジを作成し、有効化する
$ sudo ip netns exec BRIDGE ip link add dev BRIDGE-br0 type bridge
$ sudo ip netns exec BRIDGE ip link set BRIDGE-br0 up

# ブリッジNamespace内のvethインターフェースをネットワークブリッジに接続する
$ sudo ip netns exec BRIDGE ip link set HOST1-br0 master BRIDGE-br0
$ sudo ip netns exec BRIDGE ip link set HOST2-br0 master BRIDGE-br0
$ sudo ip netns exec BRIDGE ip link set HOST3-br0 master BRIDGE-br0

# 疎通確認
$ sudo ip netns exec HOST1 ping HOST2_ADDRESS -I HOST1_ADDRESS
$ sudo ip netns exec HOST1 ping HOST3_ADDRESS -I HOST2_ADDRESS

# MACアドレステーブルの確認
$ sudo ip netns exec BRIDGE bridge fdb show br BRIDGE-br0
```
