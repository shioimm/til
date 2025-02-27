# dig(1)
- ドメイン名からIPアドレスを調べる

```
$ dig example.com

$ dig -4 example.com # IPv4で調べる
$ dig -6 example.com # Ipv6で調べる
```

```
; <<>> DiG 9.10.6 <<>> example.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: <応答コード>, id: *****
;; flags: <ビットの立ったフラグ一覧>; QUERY: <n>, ANSWER: <n>, AUTHORITY: <n>, ADDITIONAL: <n>

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;  <問い合わせのドメイン名とタイプ>

;; ANSWER SECTION:
   <問い合わせた内容に対応するリソースレコード>

;; AUTHORITY SECTION:
   <権威を持つDNSサーバ名 (NSレコード)>

;; Query time: <問い合わせにかかった時間>
;; SERVER: <問い合わせ先のフルリゾルバのIPアドレス・ポート番号>
;; WHEN: <実行時刻>
;; MSG SIZE  rcvd: <受信メッセージサイズ>
```

- `QR` - Query or Response
  - 問い合わせ- 0
  - 応答 - 1
- `AA` - Aithoritative Answer
  - 対応したネームサーバーが問い合わせ部のドメイン名に対応する権威を持っているかどうか
- `TC` - Truncation

  - メッセージがtruncateされたかどうか
- `RD` - Recursion Desired
  - 再帰問い合わせかどうか
- `RA` - Recursion Available
  - 再帰問い合わせを処理できるかどうか
- `AD` - Authentic Data
  - 問い合わせ - DNSSECの検証を指示
  - 応答 - DNSSECの検証に成功したかどうか
- `CD` - Checking Disabled
  - DNSSECの検証を行わないことを指示

- [【 dig 】コマンド――ドメイン名からIPアドレスを調べる](https://atmarkit.itmedia.co.jp/ait/articles/1711/09/news020.html)
