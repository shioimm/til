# ip(1)
## ネットワークインターフェースの操作
```
# 表示
$ ip link show

# 追加
$ ip link add

# vethペアの作成
$ ip link add HOST1-veth0 type veth peer name HOST2-veth0

# ネットワークインターフェースを任意のNetwork Namespaceにセット
$ ip link set HOST1-veth0 netns HOST1
```

## ネットワークデバイスのIPアドレスの操作
```
# 表示
$ ip address show

# 追加
$ ip address add IPアドレス dev ネットワークインターフェース
```

## ルーティングテーブルの操作
```
# 表示
$ ip route show

# 追加
$ ip route add
```

## MACアドレスのキャッシュを確認する
```
$ ip neigt
```
