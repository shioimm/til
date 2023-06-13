# 状態遷移

```
<IPv6 DNS query start>
getaddrinfoを実行
---
getaddrinfoが終了 -> <IPv6 DNSクエリ終了>へ

<IPv4 DNSクエリ開始>
getaddrinfoを実行
---
getaddrinfoが終了 -> <IPv4 DNSクエリ終了>へ

<IPv6 DNSクエリ終了> -> <次の接続開始可能>へ

<IPv4 DNSクエリ終了>
IPv6スレッドが接続を開始している場合 -> <次の接続開始可能>へ

IPv6スレッドが接続を開始していない場合: Resolution Delay待機
---
Resolution Delayがタイムアウト -> <次の接続開始可能>へ
Resolution Delay中にIPv6スレッドが<IPv6 DNSクエリ終了>へ到達 -> <次の接続開始可能>へ

<次の接続開始可能>
解決済みアドレスをリストに追加
Connection Attempt Delay中は待機
TCP接続を開始していない解決済みアドレスがあれば接続開始
---
TCP接続が確立 -> <成功>へ
TCP接続が確立しないままConnection Attempt Delayがタイムアウト -> <次の接続開始可能>へ
解決済みアドレスが枯渇 -> <エラー>へ

<成功>
接続を確立していないソケットを破棄
接続を確立したソケットを返す

<エラー>
接続を確立していないソケットを破棄
例外を送出
```

## 参照
- [Happy Eyeballsとは](https://www.nic.ad.jp/ja/basics/terms/happy-eyeballs.html)
- [Happy Eyeballs: Success with Dual-Stack Hosts](https://www.ietf.org/rfc/rfc6555.txt)
- [Happy Eyeballs Version 2: Better Connectivity Using Concurrency](https://www.ietf.org/rfc/rfc8305.txt)
- https://github.com/ruby/ruby/pull/4038#issuecomment-776417560
