# nslookup(1)
- ドメイン名 -> IPアドレス
- digよりも古く機能が限られる
- インタラクティブモードが利用できる

```
$ nslookup
> google.co.jp
Server:  xxxx:xxx:xxxx:x::x # DNSサーバー名
Address: xxxx:xxx:xxxx:x::x # DNSサーバーのIPアドレス

Non-authoritative answer:
Name: google.co.jp      # 問い合わせた名前
Address: xxx.xxx.xxx.xx # 問い合わせた結果
```

#### IPv6アドレスを検索
```
$ nslookup -type=AAAA google.co.jp
Server:  xxxx:xxx:xxxx:x::x
Address: xxxx:xxx:xxxx:x::x

Non-authoritative answer:
google.co.jp has AAAA address xxxx:xxxx:xxxx:xxx::xxxx

Authoritative answers can be found from:
```

#### 経路を表示
```
$ nslookup -debug google.co.jp
Server:  xxxx:xxx:xxxx:x::x
Address: xxxx:xxx:xxxx:x::x

------------
    QUESTIONS:
  google.co.jp, type = A, class = IN
    ANSWERS:
    ->  google.co.jp
  internet address = xxx.xxx.xxx.xx
  ttl = 201
    AUTHORITY RECORDS:
    ADDITIONAL RECORDS:
------------
Non-authoritative answer:
Name: google.co.jp
Address: xxx.xxx.xxx.xx
```
