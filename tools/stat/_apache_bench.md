# Apache Bench
- Apacheの提供するベンチマークツール(`apache2-utils`に含まれる)
- Webサーバーにリクエストを送信し、秒あたりのスループットを計測する
- Apache以外のWebサーバーに対しても使用可能

```
# -n - リクエスト数の指定
# -c - コネクション数の指定

$ ab -n 100 -c 10 http://example.com
```

| オプション | 意味                                                           |
| -          | -                                                              |
| -k         | KeepAliveの有効化                                              |
| -t         | 試行時間                                                       |
| -C         | Cookieヘッダの指定                                             |
| -H         | HTTP ヘッダの指定                                              |
| -T         | Content-Typeヘッダの指定 (POST / PUT時)                        |
| -p         | bodyのファイルを指定(POST時・-Tが必要)                         |
| -l         | レスポンスのサイズがリクエストごとに異なる場合でも失敗にしない |

| 項目                 | 意味                                                               |
| -                    | -                                                                  |
| Server Software      | 最初に成功したレスポンスのHTTPヘッダに返された値                   |
| Server Hostname      | 対象のホスト名またはIPアドレス                                     |
| Server Port          | abが接続しているポート番号(デフォルトでは80)                       |
| SSL/TLS Protocol     | SSLを使用している場合に表示                                        |
| Document Path        | リクエストURI                                                      |
| Document Length      | 最初に成功したレスポンスのドキュメントのバイト数                   |
| Concurrency Level    | テストで使用された並列クライアント数                               |
| Time taken for tests | 最初のソケットが作成されてから最後のレスポンスを受信するまでの時間 |
| Complete requests    | 成功したリクエストの数                                             |
| Failed requests      | 失敗したリクエストの数                                             |
| Write errors         | 書き込み中に失敗したエラーの数                                     |
| Non-2xx responses    | レスポンスのステータスコードが200系列ではなかったレスポンス数      |
| Keep-Alive requests  | Keep-Aliveリクエストが発生したコネクション数                       |
| Total body sent      | テスト中に送信されたリクエストボディのバイト数                     |
| Total transferred    | サーバーから受信した総バイト数                                     |
| HTML transferred     | サーバから受信したドキュメントの総バイト数                         |
| Requests per second  | 秒あたりのリクエスト数                                             |
| Time per request     | リクエストあたりの平均処理時間                                     |
| Transfer rate        | `totalread / 1024 / timetaken`の式で計算される転送率               |

#### Connection Times (ms)

| 項目       | 意味     |
| -          | -        |
| Connect    | 接続時間 |
| Processing | 処理時間 |
| Waiting    | 待機時間 |
| Total      | 合計時間 |
| min        | 最小値   |
| mean       | 平均値   |
| [+/-sd]    | 標準偏差 |
| median     | 中央値   |
| max        | 最大値   |

#### Percentage of the requests served within a certain time (ms)

| 項目 | 意味                                            |
| -    | -                                               |
|  50% | 全リクエストの50%を完了させるためにかかった時間 |
|  66% | 全リクエストの66%を完了させるためにかかった時間 |
|  75% | 全リクエストの75%を完了させるためにかかった時間 |
|  80% | 全リクエストの80%を完了させるためにかかった時間 |
|  90% | 全リクエストの90%を完了させるためにかかった時間 |
|  95% | 全リクエストの95%を完了させるためにかかった時間 |
|  98% | 全リクエストの98%を完了させるためにかかった時間 |
|  99% | 全リクエストの99%を完了させるためにかかった時間 |
| 100% | 全リクエストを完了させるためにかかった時間      |

## 参照
- [ab - Apache HTTP server benchmarking tool](https://httpd.apache.org/docs/2.4/programs/ab.html)
