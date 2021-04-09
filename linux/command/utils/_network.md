# ネットワーク
### 疎通確認
```
$ ping ドメイン名 or IPアドレス
```

- 内部的にはICMPプロトコルを使用してエコーリクエスト・エコーリプライを行っている

```
$ ping -c 3 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) バイトのデータ
64 バイト応答 送信元 8.8.8.8: icmp_seq=1 ttl=116 時間=114 ミリ秒
64 バイト応答 送信元 8.8.8.8: icmp_seq=2 ttl=116 時間=113 ミリ秒
64 バイト応答 送信元 8.8.8.8: icmp_seq=3 ttl=116 時間=113 ミリ秒

--- 8.8.8.8 ping 統計 ---
送信パケット数 3, 受信パケット数 3, パケット損失 0%, 時間 2002ミリ秒
rtt 最小/平均/最大/mdev = 112.631/113.443/114.203/0.642ミリ秒

# 3リクエストに対して3レスポンスがあり、パケット損失は0
```

### ホストマシンのIPアドレス確認
```
$ ip address show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever

# 1: lo - lo = ネットワークインターフェース
# inet 127.0.0.1 - 127.0.0.1 = IPアドレス
```

### ルーティングテーブル確認
```
$ ip route show
default via ネクストホップ
ネクストホップ dev ネクストホップの次のネクストホップ
```

### 経路確認
```
$ traceroute ドメイン名 or IPアドレス
```

- ホストマシンから送出したパケットが指定の宛先に届くまでにたどるルーターのIPアドレスの経路を表示する

### DNS要求(DNSへ名前解決を問い合わせる)
```
$ nslookup ドメイン名
$ nslookup IPアドレス

# 対話モードがなく、シンプルな表示
$ host ホスト名
$ host ドメイン名
$ host IPアドレス

# 対話モードがなく、バッチモードを備える / 細かくオプション指定できる
$ dig ホスト名
$ dig ドメイン名
$ dig IPアドレス
```

### Whois情報(ドメインの情報)を表示する
```
$ whois ドメイン名
$ whois IPアドレス
```

### 指定のドメインのサーバーを表示する
```
$ dig ドメイン名 a +short
$ whois IPアドレス
```

### ネームサーバーを表示する
```
$ dig ドメイン名 ns +short
```

###  自身のプライベートIPアドレスを表示する
```
$ sudo ifconfig
```

### 指定のドメインにたどり着くまでのネットワークの経路を表示する
```
$ traceroute リモートホスト名(アドレス)
```
