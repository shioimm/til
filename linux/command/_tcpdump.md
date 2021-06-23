# `tcpdump(1)`
- インターネットトラフィックをリアルタイムで表示する(パケットキャプチャ)
- TCPセグメント以外の全種類のネットワークパケットを表示可能
- ソケットアプリケーション開発時のデバッグツールとして有効

## TCPの表示項目
```
src > dst: flags data-seqno ack window urg <options>
```

| 項目名       | 説明                                                              |
| -            | -                                                                 |
| `src`        | 送信元ノードIPアドレス・ポート番号(`-e`オプションでMACアドレス)   |
| `dst`        | 送信先ノードIPアドレス・ポート番号(`-e`オプションでMACアドレス)   |
| `flags`      | TCPの制御フラグ                                                   |
| `data-seqno` | 当該パケットが対応するシーケンス番号範囲                          |
| `ack`        | 当該コネクションの受信側が次に期待するシーケンス番号(`ack n`)     |
| `window`     | 当該コネクションの受信側が次に受信可能と通知したバイト数(`win n`) |
| `urg`        | 当該セグメント内の`n`の位置に緊急データが存在すること(`urg n`)    |
| `options`    | 当該セグメントが持つTCPオプション                                 |

```
$ sudo tcpdump -i lo -tnlA "tcp and port 54321"
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 262144 bytes
IP 127.0.0.1.xxxxx > 127.0.0.1.54321: Flags [S], seq 1020523225, win 65495, options [mss 65495,sackOK,TS val 2697659148 ecr 0,nop,wscale 7], length 0
E..<..@.@..............1<............0.........
............
IP 127.0.0.1.54321 > 127.0.0.1.xxxxx: Flags [S.], seq 2500527594, ack 1020523226, win 65483, options [mss 65495,sackOK,TS val 2697659148 ecr 2697659148,nop,wscale 7], length 0
E..<..@.@.<..........1......<........0.........
............
IP 127.0.0.1.xxxxx > 127.0.0.1.54321: Flags [.], ack 1, win 512, options [nop,nop,TS val 2697659148 ecr 2697659148], length 0
E..4..@.@..............1<............(.....
........
IP 127.0.0.1.xxxxx > 127.0.0.1.54321: Flags [P.], seq 1:7, ack 1, win 512, options [nop,nop,TS val 2697911548 ecr 2697659148], length 6
E..:..@.@..............1<..................
........Hello

IP 127.0.0.1.54321 > 127.0.0.1.xxxxx: Flags [.], ack 7, win 512, options [nop,nop,TS val 2697911548 ecr 2697911548], length 0
E..4.a@.@.H`.........1......<........(.....
........
```

## UDPの表示項目
```
$ sudo tcpdump -i lo -tnlA "udp and port 54321"
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 262144 bytes
IP 127.0.0.1.xxxxx > 127.0.0.1.54321: UDP, length 6
E.."j`@.@..h.........`.1...!Hello

# "udp and port 54321" - UDPかつポート54321番の通信をキャプチャする
```

# ICMPの表示項目
```
$ sudo tcpdump -tn -i any icmp
IP xxx.xxx.xxx.xxx > 8.8.8.8: ICMP echo request, id 5, seq 1, length 64
IP 8.8.8.8 > xxx.xxx.xxx.xxx: ICMP echo reply,   id 5, seq 1, length 64

# any  - 全ての種類のネットワークインターフェース
# icmp - パケットキャプチャの対象をICMPに絞る
```

## オプション
- `-t` - 時刻に関する情報を出力しない
- `-n` - IPアドレスを名前解決しない
- `-i` - パケットキャプチャを行う対象のネットワークインターフェース
- `-e` - Ethernetのヘッダ情報を表示する
- `-l` - Network Namespaceで`tcpdump(1)`を使用する際に指定する
- `-A` - キャプチャした内容をASCII文字列として表示させる

## MacOSでパケットトレースを行う場合
- [Recording a Packet Trace](https://developer.apple.com/documentation/network/recording_a_packet_trace#//apple_ref/doc/uid/DTS10001707-CH1-SECNOTES)
```
# ネットワークインターフェース名を取得
$ networksetup -listallhardwareports

# tcpdump(1)を実行
$ sudo tcpdump -i ネットワークインターフェース名 -n
$ sudo tcpdump -s0 -A host google.com
```

## 参照
- Linuxプログラミングインターフェース 61章
