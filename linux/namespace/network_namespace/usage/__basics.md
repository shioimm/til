# 基本操作

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

## 参照
- Linuxで動かしながら学ぶTCP/IPネットワーク入門
