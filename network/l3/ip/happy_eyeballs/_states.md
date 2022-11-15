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

```
Start
-> getaddrinfo
  -> IPv6 getaddrinfo -> IPv6-getaddrinfo-finished
  -> IPv4 getaddrinfo -> IPv4-getaddrinfo-finished

IPv6-getaddrinfo-finished
-> TCPハンドシェイクを開始していないIPアドレスがある場合: IPv6アドレスで接続試行
   -> 接続試行                             -> Success
   -> IPv4アドレス取得                     -> IPv6-IPv4-getaddrinfo-finished
   -> Connection Attempt Delayタイムアウト -> IPv6-getaddrinfo-finished

IPv4-getaddrinfo-finished
-> Resolution Delay
   -> Resolution Delayタイムアウト -> IPv4-getaddrinfo-and-RESOLUTION_DELAY-finished
   -> IPv6アドレス取得             -> IPv6-getaddrinfo-finished

IPv4-getaddrinfo-and-RESOLUTION_DELAY-finished
-> IPv4アドレスで接続試行
   -> 接続試行                             -> Success
   -> IPv6アドレス取得                     -> IPv6-IPv4-getaddrinfo-finished
   -> Connection Attempt Delayタイムアウト -> IPv4-getaddrinfo-and-RESOLUTION_DELAY-finished

IPv6-IPv4-getaddrinfo-finished
-> 接続未試行のIPアドレスがあり、TCPハンドシェイク中かつCADタイムアウト済: IPv6アドレスで接続試行
   接続未試行のIPアドレスがあり、TCPハンドシェイク中かつCADタイムアウト済: IPv4アドレスで接続試行
   接続未試行のIPアドレスがあり、TCPハンドシェイク中かつCADタイムアウト未: Connection Attempt Delay
   接続未試行のIPアドレスがない場合: アドレス枯渇
   -> 接続試行                             -> Success
   -> Connection Attempt Delayタイムアウト -> IPv6-IPv4-getaddrinfo-finished
   -> アドレス枯渇                         -> Error

Success
-> 接続済みソケットを返す

Error
-> 例外を送出する
```

## 参照
- [Happy Eyeballsとは](https://www.nic.ad.jp/ja/basics/terms/happy-eyeballs.html)
- [Happy Eyeballs: Success with Dual-Stack Hosts](https://www.ietf.org/rfc/rfc6555.txt)
- [Happy Eyeballs Version 2: Better Connectivity Using Concurrency](https://www.ietf.org/rfc/rfc8305.txt)
- https://github.com/ruby/ruby/pull/4038#issuecomment-776417560
