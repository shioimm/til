# 異なるセグメント間でのネットワーク接続
- Network Namespace同士をネットワークセグメントをまたいで接続する

---

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

## 参照
- Linuxで動かしながら学ぶTCP/IPネットワーク入門
