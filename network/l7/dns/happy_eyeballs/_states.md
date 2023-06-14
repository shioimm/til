# 状態遷移
### IPv6スレッド
#### `IPv6 DNSクエリ開始`
- getaddrinfoを実行
  - getaddrinfoが終了 -> `IPv6 DNSクエリ終了`へ遷移

#### `IPv6 DNSクエリ終了`
- 他のスレッドに通知
  - -> `次の接続開始可能`へ (IPv6アドレス)

### IPv4スレッド
#### `IPv4 DNSクエリ開始`
- getaddrinfoを実行
  - getaddrinfoが終了 -> `IPv4 DNSクエリ終了`へ遷移

#### `IPv4 DNSクエリ終了`
- `IPv6 DNSクエリ終了`通知を受信済みの場合: -> `次の接続開始可能`へ (IPv6アドレス)
- `IPv6 DNSクエリ終了`通知を受信していない場合: -> `Resolution Delay待機`へ

#### `Resolution Delay待機`
- 待機
  - タイムアウト前に`IPv6 DNSクエリ終了`通知を受信した場合: -> `次の接続開始可能`へ (IPv6アドレス)
  - タイムアウトした場合: -> `次の接続開始可能`へ (IPv4アドレス)

### 共通
#### `次の接続開始可能`
- 解決済みアドレスをリストに追加
- Connection Attempt Delay中の場合: 待機
  - 待機終了 -> `次の接続開始可能`へ (アドレスリストの先頭アドレス)
- Connection Attempt Delayではない場合: アドレスリストの先頭アドレスで接続開始、Connection Attempt Delay開始
  - TCP接続中に`IPv6 DNSクエリ終了`通知を受信した場合: -> 当該スレッドは`次の接続開始可能`へ (IPv6アドレス)
  - TCP接続が確立した場合: -> `成功`へ
  - TCP接続が確立しないままタイムアウトの場合: -> `次の接続開始可能`へ (アドレスリストの先頭アドレス)
- 解決済みアドレスが枯渇の場合: -> `エラー`へ

#### `成功`
- 接続を確立していないソケットを破棄
- 接続を確立したソケットを返す

#### エラー
- 接続を確立していないソケットを破棄
- 例外を送出

## 参照
- [Happy Eyeballsとは](https://www.nic.ad.jp/ja/basics/terms/happy-eyeballs.html)
- [Happy Eyeballs: Success with Dual-Stack Hosts](https://www.ietf.org/rfc/rfc6555.txt)
- [Happy Eyeballs Version 2: Better Connectivity Using Concurrency](https://www.ietf.org/rfc/rfc8305.txt)
- https://github.com/ruby/ruby/pull/4038#issuecomment-776417560
