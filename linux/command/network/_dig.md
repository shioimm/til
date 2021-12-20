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
;; ->>HEADER<<- opcode: QUERY, status: NOERROR または NXDOMAIN, id: *****
;; flags: 回答の意味を示すフラグ; QUERY: n (レコード数), ANSWER: n, AUTHORITY: n, ADDITIONAL: n

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;  問い合わせ内容

;; ANSWER SECTION:
   問い合わせた内容に対応するリソースレコード

;; AUTHORITY SECTION:
   権威を持つDNSサーバ名(NSレコード)

;; Query time: 問い合わせにかかった時間
;; SERVER: 問い合わせたネームサーバー
;; WHEN: 実行時刻
;; MSG SIZE  rcvd: 受信メッセージサイズ
```

- [【 dig 】コマンド――ドメイン名からIPアドレスを調べる](https://atmarkit.itmedia.co.jp/ait/articles/1711/09/news020.html)
