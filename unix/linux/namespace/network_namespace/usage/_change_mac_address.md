# ネットワークインターフェースのMACアドレス変更
- デフォルトではランダムなMACアドレスがvethインターフェースに割り振られる

```
$ sudo ip netns exec NAMESPACE ip link set dev VETHNAME-veth0 address MACADDRESS

# アドレスの確認
$ sudo ip netns exec NAMESPACE ip link show | grep link/ether

# MACアドレスのキャッシュを削除する
$ sudo ip netns exec NAMESPACE ip neigh flush all
```

## 参照
- Linuxで動かしながら学ぶTCP/IPネットワーク入門
