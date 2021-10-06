# iptables(1)
- NATテーブルの設定を行う

```
# NATテーブルの設定を表示
$ iptables -t nat -L

# NATテーブルにSorce NATのルールを追加
$ iptables -t nat \
           -A POSTROUTING \ # チェイン追加: ルーティングが終わってパケットから出ていく直前
           -s 送信元IPアドレス \
           -o 出力先ネットワークインターフェース \
           -j MASQUERADE # 処理内容を追加: Source NAT

# NATテーブルにDestination NATのルールを追加
$ iptables -t nat \
           -A PREROUTING \ # チェイン追加: インターフェースからパケットが入ってきた直後
           -p tcp \ # トランスポート層のプロトコル
           --dport ポート番号 \
           -d 変換前IPアドレス \
           -j DNAT \ # 処理内容を追加: Destination NAT↲
           --to-destination # 変換後IPアドレス
```
