# `tcpdump(1)`
- 参照: Linuxプログラミングインターフェース 61章

## TL;DR
- インターネットトラフィックをリアルタイムで表示する(パケットキャプチャ)
- TCPセグメント以外の全種類のネットワークパケットを表示可能
- ソケットアプリケーション開発時のデバッグツールとして有効

## 表示項目
```
src > dst: flags data-seqno ack window urg <options>
```

| 項目名       | 説明                                                              |
| -            | -                                                                 |
| `src`        | 送信元IPアドレス・ポート番号                                      |
| `dst`        | 宛先IPアドレス・ポート番号                                        |
| `flags`      | TCPの制御フラグ                                                   |
| `data-seqno` | 当該パケットが対応するシーケンス番号範囲                          |
| `ack`        | 当該コネクションの受信側が次に期待するシーケンス番号(`ack n`)     |
| `window`     | 当該コネクションの受信側が次に受信可能と通知したバイト数(`win n`) |
| `urg`        | 当該セグメント内の`n`の位置に緊急データが存在すること(`urg n`)    |
| `options`    | 当該セグメントが持つTCPオプション                                 |

```
$ ping 8.8.8.8
```

```
$ sudo tcpdump -tn -i any icmp
IP xxx.xxx.xxx.xxx > 8.8.8.8: ICMP echo request, id 5, seq 1, length 64
IP 8.8.8.8 > xxx.xxx.xxx.xxx: ICMP echo reply,   id 5, seq 1, length 64

# -t - 時刻に関する情報を出力しない
# -n - IPアドレスを名前解決しない
# -i - パケットキャプチャを行う対象のネットワークインターフェース
# icmp - パケットキャプチャの対象をICMPに絞る
```
