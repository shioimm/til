#### IPv6を無効 / 有効化 (macOS)

```
$ sudo networksetup -setv6off Wi-Fi
$ networksetup -getinfo Wi-Fi # 確認
$ sudo networksetup -setv6automatic Wi-Fi
```

#### curlをc-aresとリンクして使う

```
$ brew install c-ares openssl@3
$ git clone https://github.com/curl/curl.git
$ cd curl
$ autoreconf -fi
$ ./configure \
  --prefix=$HOME/local-curl \
  --with-ssl=$(brew --prefix openssl@3) \
  --enable-ares=$(brew --prefix c-ares)

$ make -j
$ make install
$ HOME/local-curl/bin/curl -V # => c-ares/*.*.*が含まれていればOK
$ HOME/local-curl/bin/curl --happy-eyeballs-timeout-ms 250 --trace-ascii - https://example.com/

# 検証
$ sudo tcpdump -i any -n -s 0 port '(53 or 853 or 443)' and '(udp or tcp)' | grep example

tcpdump: data link type PKTAP
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type PKTAP (Apple DLT_PKTAP), snapshot length 524288 bytes
12:46:59.069382 IP6 *:*:*:*:*:*:*:*.59791 > *:*:*:*:*:*:*:*.53: 12749+ [1au] A? example.com. (52)
12:46:59.069555 IP6 *:*:*:*:*:*:*:*.59791 > *:*:*:*:*:*:*:*.53: 551+ [1au] AAAA? example.com. (52)
```
