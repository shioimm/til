# MTU (Maximum Transmission Unit)
- Ethernetで扱えるデータ量の最大サイズ
- MTU設定値よりも大きなサイズのパケットを送信する場合、MTUのサイズまで分割して送信する
- 最大1500バイト - IEEE 802.3で定められたEthernetの最大サイズと同じ

```
# enp0s3のMTUを表示
$ ip link show enp0s3

# enp0s3のMTUを一時的に9000バイトへ変更
$ sudo ip link set enp0s3 mtu 9000
```

#### Jumbo Frame
- 9000バイト
- MTUを1500バイトよりも大きくしてスループットを向上させるための定義
- ホストがJumbo Frameを利用する場合であっても、
  経路中にMTUの設定サイズが小さいノードが存在していた場合は
  そのノードにパケットが到達した時点で分割が発生する

## 参照
- 達人が教えるWebパフォーマンスチューニング 〜ISUCONから学ぶ高速化の実践
