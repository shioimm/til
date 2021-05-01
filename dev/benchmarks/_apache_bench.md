# Apache Bench
- Apacheの提供するベンチマークツール(`apache2-utils`に含まれる)
- Webサーバーにリクエストを送信し、秒あたりのスループットを計測する
- Apache以外のWebサーバーに対しても使用可能

## Usage
### `ab`コマンド
- `-n` - リクエスト数の指定
- `-c` - コネクション数の指定
```
$ ab -n 100 -c 10 http://example.com
```

### 結果
- Server Software
  - 最初に成功したレスポンスのHTTPヘッダに返された値
- Server Hostname
  - 対象のホスト名またはIPアドレス
- Server Port
  - abが接続しているポート番号(デフォルトでは80)
- SSL/TLS Protocol
  - SSLを使用している場合に表示
- Document Path
  - リクエストURI
- Document Length
  - 最初に成功したレスポンスのドキュメントのバイト数
- Concurrency Level
  - テストで使用された並列クライアント数
- Time taken for tests
  - 最初のソケットが作成されてから最後のレスポンスを受信するまでの時間
- Complete requests
  - 成功したリクエストの数
- Failed requests
  - 失敗したリクエストの数
- Write errors
  - 書き込み中に失敗したエラーの数
- Non-2xx responses
  - レスポンスのステータスコードが200系列ではなかったレスポンス数
- Keep-Alive requests
  - Keep-Aliveリクエストが発生したコネクション数
- Total body sent
  - テスト中に送信されたリクエストボディのバイト数
- Total transferred
  - サーバーから受信した総バイト数
- HTML transferred
  - サーバから受信したドキュメントの総バイト数
- Requests per second
  - 秒あたりのリクエスト数
- Time per request
  - リクエストあたりの平均処理時間
- Transfer rate
  - `totalread / 1024 / timetaken`の式で計算される転送率

## 参照
- [ab - Apache HTTP server benchmarking tool](https://httpd.apache.org/docs/2.4/programs/ab.html)
