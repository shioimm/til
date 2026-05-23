# c-ares
## getaddrinfoがサポートしていてc-aresがサポートしていないもの
- NSS経路での名前解決
- `/etc/services`によるサービス名 -> ポート番号の解決 (c-ares独自のAPIがある)
- `AI_ADDRCONFIG` (OS/libc実装依存なのでc-aresが提供しているAPIと完全互換ではない)
- `/etc/gai.conf`によるaddress selection policy (c-ares自身のソート制御がある)
