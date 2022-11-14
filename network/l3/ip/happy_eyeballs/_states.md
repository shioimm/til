# 状態遷移
#### 名前解決

```
(1) AAAAクエリの送信 / Aクエリの送信

(2-1) 先にAAAAクエリの応答があった場合
-> Aクエリの応答があるまで250秒間待つ (Resolution Delay)

  (2-1-1) Aクエリの応答があった場合
  -> IPv6アドレスの接続試行へ進む / IPv4アドレスをアドレスリストの先頭に加える

  (2-1-2) Aクエリの応答がなかった場合
  -> IPv6アドレスの接続試行へ進む / Aクエリの応答を待つ (返ってきたらアドレスリストの先頭に加える)

(2-2) 先にAクエリの応答があった場合
-> AAAA応答を50ミリ秒 (推奨値) 待つ (Resolution Delay)

  (2-2-1) Resolution Delay時間内に肯定的なAAAA応答を受信した場合
  -> IPv6アドレスの接続試行へ進む / IPv4アドレスをアドレスリストの先頭に加える

  (2-2-2) Resolution Delay時間内に否定的なAAAA応答を受信、またはAAAA応答を受信しなかった場合
  -> これまでに返されたIPv4アドレスのソートを行い、スタッガード接続する

    (2-2-2-1) スタッガード接続が確立される前にAAAA応答が到着した場合
    -> 新しく受信したIPv6アドレスを利用可能な候補アドレスのリストに組み込み、
       接続が確立するまでIPv6アドレスを追加して接続試行のプロセスを継続する
```

## 参照
- [Happy Eyeballsとは](https://www.nic.ad.jp/ja/basics/terms/happy-eyeballs.html)
- [Happy Eyeballs: Success with Dual-Stack Hosts](https://www.ietf.org/rfc/rfc6555.txt)
- [Happy Eyeballs Version 2: Better Connectivity Using Concurrency](https://www.ietf.org/rfc/rfc8305.txt)
