# 状態遷移
#### 名前解決

```
(1) AAAAクエリの送信 / Aクエリの送信

(2-1) 先にAAAAクエリの応答を受信した場合
-> IPv6アドレスの接続試行へ進む / Aクエリの応答を受信したらIPv4アドレスをアドレスリストの先頭に加える

(2-2) 先にAクエリの応答を受信した場合
-> AAAA応答を50ms (推奨値) 待つ (Resolution Delay)

  (2-2-1) Resolution Delay時間内に肯定的なAAAA応答を受信した場合
  -> IPv6アドレスの接続試行へ進む / IPv4アドレスをアドレスリストの先頭に加える

  (2-2-2) Resolution Delay時間内に否定的なAAAA応答を受信、またはAAAA応答を受信しなかった場合
  -> これまでに返されたIPv4アドレスでアドレスリストをソートし、接続試行へ進む

    (2-2-2-1) 接続が確立される前にAAAA応答が到着した場合
    -> 接続試行を続ける / IPv6アドレスをアドレスリストの先頭に加える
```

#### 接続試行

```
(1) 対象のアドレスの接続試行を開始する

(2-1) 接続が確立した場合
-> 接続済みソケットを返す

(2-2) 接続が失敗した場合
-> 例外を送出する

(2-3) 接続が確立できないまま250ms経過した場合 (Connection Attempt Delay)
-> アドレスリストの先頭のアドレスの接続試行に進む
```

## 参照
- [Happy Eyeballsとは](https://www.nic.ad.jp/ja/basics/terms/happy-eyeballs.html)
- [Happy Eyeballs: Success with Dual-Stack Hosts](https://www.ietf.org/rfc/rfc6555.txt)
- [Happy Eyeballs Version 2: Better Connectivity Using Concurrency](https://www.ietf.org/rfc/rfc8305.txt)
