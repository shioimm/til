# traceroute / traceroute6
- 自ホストから宛先に辿り着くまでのネットワークノードの経路 (IPアドレス) を表示
- LinuxではUDPデータグラムで通信を行う (ICMP到達不能メッセージを利用して経路情報を収集する)
- Linux以外のホストではICMPで通信を行う (ICMP応答を利用して経路情報を収集する)
- TCPのSYNパケットを利用するケースもある

```
$ traceroute ドメイン名 or IPアドレス
```

```
$ traceroute localhost

# 宛先ホスト、最大経路数
traceroute to localhost (127.0.0.1), 64 hops max, 52 byte packets

# ホップ数、宛先ホスト (IPアドレス) 、RTT (1回目) 、RTT (2回目) 、RTT (3回目)
 1  localhost (127.0.0.1)  1.807 ms  0.055 ms  0.038 ms
```

#### `*`
- タイムアウト (送信したパケットに対して何も返って来なかった)、
  あるいはWindows Firewallを有効にしているホストに対する送信

## 参照
- [【Linux】traceroute の結果(!X, !H, `*`アスタリスク)の原因/理由,利用ポートについて～](https://milestone-of-se.nesuke.com/sv-basic/linux-basic/traceroute-result/)
