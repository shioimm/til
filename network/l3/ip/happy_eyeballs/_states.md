# 状態遷移

```
(1) getaddrinfo (IPv6) / getaddrinfo (IPv4)

(2-1) getaddrinfo (IPv6) の応答を先に受信した場合
-> IPv6アドレスで接続試行を行う

   (2-1-1) getaddrinfo (IPv4) の応答を受信した場合
   -> IPv4アドレスをアドレスリストの先頭に加える

(2-2) getaddrinfo (IPv4) の応答を先に受信した場合
-> getaddrinfo (IPv6) 応答を50ms待つ (Resolution Delay)

  (2-2-1) Resolution Delay中に肯定的なgetaddrinfo (IPv6) の応答を受信した場合
  -> IPv6アドレスの接続試行を行う
     IPv4アドレスをアドレスリストの先頭に加える

  (2-2-2) Resolution Delay中に否定的なgetaddrinfo (IPv6) の応答を受信、または応答を受信しなかった場合
  -> IPv4アドレスで接続試行を行う

    (2-2-2-1) 接続が確立される前にgetaddrinfo (IPv6) の応答を受信した場合
    -> IPv4アドレスで接続試行を続ける
       IPv6アドレスをアドレスリストの先頭に加える

(3-1) 接続が確立した場合
-> 接続済みソケットを返し、他の接続試行を破棄する

(3-2) 接続に失敗した場合
-> 例外を送出する

(3-3) 接続が確立できないまま250ms経過した場合 (Connection Attempt Delay)
-> アドレスリストの先頭のアドレスの接続試行に進む
```

## 参照
- [Happy Eyeballsとは](https://www.nic.ad.jp/ja/basics/terms/happy-eyeballs.html)
- [Happy Eyeballs: Success with Dual-Stack Hosts](https://www.ietf.org/rfc/rfc6555.txt)
- [Happy Eyeballs Version 2: Better Connectivity Using Concurrency](https://www.ietf.org/rfc/rfc8305.txt)
