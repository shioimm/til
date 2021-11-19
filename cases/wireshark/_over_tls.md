# TLSで暗号化された通信をダンプする (TLS、HTTP/2、QUIC)
- Chromeから復号用の鍵を取り出しkeylogfile.txtに保存

```
$ export SSLKEYLOGFILE=$HOME/Desktop/keylogfile.txt
$ open -a firefox
```

- Wireshark > Preference > Protocols > TLS
- (Pre)-Master-Secret log filenameにkeylogfile.txtを指定

## 参照
- [Using the (Pre)-Master-Secret](https://gitlab.com/wireshark/wireshark/-/wikis/TLS#using-the-pre-master-secret)
- WEB+DB PRESS Vol.123 HTTP/3入門
- パケットキャプチャの教科書
