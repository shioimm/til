# ネットワークブリッジを使用したネットワーク接続
- Network Namespace同士をネットワークブリッジを介して続する

---

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

## 参照
- Linuxで動かしながら学ぶTCP/IPネットワーク入門
