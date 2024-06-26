# HTTP/3コネクション
## コネクションの確立
#### HTTP/3に対応しているかどうかの確認
1. クライアント -> サーバー
    - HTTP/1.1もしくはHTTP/2でリクエストを送信する
2. クライアント <- サーバー
    - サーバー自身がHTTP/3に対応していることをクライアントに通知
    - Alt-Svcヘッダを利用

```
Alt-Svc: h3=":ポート番号" ; ma=この情報の有効期間

// 443番ポート: UDPのHTTPSポート
```

#### QUICコネクションの確立
- クライアント -> サーバー
  - 指定されたポートに対してQUICコネクションの確立を試行する
  - アプリケーションプロトコルのネゴシエーションに則ってHTTP/3通信を行うことに合意する

#### 通信パラメータの設定
- クライアント -> サーバー / クライアント <- サーバー
  - 両ノードがそれぞれControlストリームをオープン (HTTP/3通信の終了時まで維持)
  - 両ノードがそれぞれControlストリームで`SETTINGS`フレームを利用して通信に関するパラメータを通知
  - クライアントは`SETTINGS`フレームの送信直後からHTTPメッセージを送信できる

## HTTPメッセージの送受信
- クライアント <-> サーバー
  - クライアントはRequestストリームをオープン (複数のRequestストリームが並列に使用される)
  - クライアントはRequestストリームでリクエストが格納された`HEADERS`フレーム・`DATA`フレームを送信
  - サーバーはRequestストリームでレスポンスが格納された`HEADERS`フレームと`DATA`フレームを送信

## 通信の終了
1. クライアント <- サーバー
    - HTTPの送受信が終わるか、通信を継続できない不具合が発生した場合
    - サーバーがControlストリームをオープン
    - サーバーは`GOAWAY`フレームを送信し、受信中のHTTPメッセージの受信が完了するのを待つ
2. クライアント <- サーバー
    - サーバーがQUICでの即時クローズを実行(QUICの`CONNECTION_CLOSE`フレーム:0×1dを送信)

#### QUICの`CONNECTION_CLOSE`フレームに格納されるエラーコードの種類

| 種類                        | 内容                                       |
| -                           | -                                          |
| `H3_NO_ERROR`               | 正常終了                                   |
| `H3_GENERAL_PROTOCOL_ERROR` | 具体的には示さないが仕様違反により切断     |
| `H3_INTERNAL_ERROR`         | HTTPスタック内のエラー                     |
| `H3_MISSING_SETTING`        | 必要なSETTINGSフレームを受信できなかった   |
| `H3_VERSION_FALLBACK`       | HTTP/3でリクエストに答えられない           |

## 参照
- Real World HTTP 第2版
- WEB+DB PRESS Vol.123 HTTP/3入門
