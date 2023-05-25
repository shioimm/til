# EDNS0 (RFC 6891)
- 512バイトを超えるDNSメッセージをUDPで扱えるようにするためのDNS拡張方式
- UDPデータサイズを指定することが可能になる
- DNSメッセージヘッダ (RCODEやフラグ) 、DNSラベルタイプ、DNSメッセージのUDPペイロードサイズなどが
  拡張の対象となる

```
$ dig +norec +edns ***.com

; <<>> DiG 9.10.6 <<>> +norec +edns ***.com
; ...

;; OPT PSEUDOSECTION: <- 追加される
; EDNS: version: 0, flags:; udp: 4096
; ...
```

## 参照
[EDNS0とは](https://www.nic.ad.jp/ja/basics/terms/edns0.html)
