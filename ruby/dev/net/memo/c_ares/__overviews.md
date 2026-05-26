# c-ares
- https://c-ares.org
- https://github.com/c-ares/c-ares

## 特徴
- 非同期・複数並行でDNS問い合わせを行うことができる
- A / AAAA以外にHTTPS / SVCB / SRV / MX / TXTなど、任意のDNS RRを問い合わせることができる
- Dynamic Server Timeout Calculation
  - DNSサーバごとに過去の応答時間メトリクスを保持し、問い合わせタイムアウトを動的に調整する

### 機能
- Failed Server Isolation
  - 応答しない、または問題のあるDNSサーバの優先度を一時的に下げ、5秒間リトライをしないようにする
- Query Cache
  - 成功したDNS応答やSOAを含むNXDOMAIN応答をTTLに従ってキャッシュする
- DNS 0x20 Query Name Case Randomization
  - UDPのDNS問い合わせにおいて、問い合わせ先ホスト名の大文字・小文字をランダム化することで、
    クエリに追加のエントロピーを提供しoff-path cache poisoning攻撃を緩和する
- Event Thread
  - 各ソケットの読み取りおよび書き込みイベントをc-aresに通知するためのイベントループをc-ares自身が管理する
- System Configuration Change Monitoring
  - ネットワーク設定やDNS設定の変更を監視し、変更が検出されたら新しい設定を読み込んで現在のc-ares設定に反映させる
  - AndroidとDOSは除外
- DNS Cookies
- TCP FastOpen (0-RTT)

## getaddrinfoがサポートしていてc-aresがサポートしていないもの
- NSS経路での名前解決
- `/etc/services`によるサービス名 -> ポート番号の解決 (c-ares独自のAPIがある)
- `AI_ADDRCONFIG` (OS/libc実装依存なのでc-aresが提供しているAPIと完全互換ではない)
- `/etc/gai.conf`によるaddress selection policy (c-ares自身のソート制御がある)
