# ストリーム(HTTP/2)
## TL;DR
- 一本のTCP接続の内部に作られる仮想のTCPソケット
  - 1ストリーム上で1リクエスト・1レスポンスのやりとりが行われる
  - ストリームはフレームに付随するフラグによって簡単に作ったり閉じたりすることができる
  - ストリーム単位ではTCPハンドシェイクは不要
  - ストリームIDの数値とTCPの通信容量が許す限り並列接続を行うことができる
- クライアント・サーバーはそれぞれ複数のストリームを作成し、
  実際には一つのTCPコネクション上で直列化して送信する
  - ブラウザから複数のタブを開いていてもリクエストは一つの接続にまとめられる

## ストリームの状態
- ストリームID 0以外のストリームは状態を持つ
- ストリームの状態は最初idle状態から始まり、ヘッダを受け取ると即時通信可能なopen状態になる
- 1コネクションにつき使用済みの各ストリームは再利用されなくなる

### 状態
- idle
  - 遷移先 - open / reserved(local) / reserved (remote)
  - 送信可能フレーム - `HEADERS` / `PUSH_PROMISE`(予約ID)
  - 受信可能フレーム - `HEADERS` / `PRIORITY`
-  reserved(local)
  - 遷移先 - half closed(remote) / closed
  - 送信可能フレーム - `HEADERS` / `RST_STREAM` / `PRIORITY`
  - 受信可能フレーム - `RST_STREAM` / `PRIORITY` / `WINDOW_UPDATE`
- reserved(remote)
  - 遷移先 - half closed(remote) / closed
  - 送信可能フレーム - `RST_STREAM` / `PRIORITY` / `WINDOW_UPDATE`
  - 受信可能フレーム - `HEADERS` / `RST_STREAM` / `PRIORITY`
-  open
  - 遷移先 - half closed(local) / half closed(remote) / closed
  - 送信可能フレーム - `HEADERS(END_STREAM)` / `RST_STREAM`
  - 受信可能フレーム - `PUSH_PROMISE`以外
- half closed(local)
  - 遷移先 - closed
  - 送信可能フレーム - `RST_STREAM` / `PRIORITY` / `WINDOW_UPDATE`
  - 受信可能フレーム - 全て可能
- half closed(remote)
  - 遷移先 - closed
  - 送信可能フレーム - `HEADERS(END_STREAM)` / `RST_STREAM`
  - 受信可能フレーム - `RST_STREAM` / `PRIORITY` / `WINDOW_UPDATE`
- close
  - 遷移先 - reserved
  - 送信可能フレーム - `PRIORITY`
  - 受信可能フレーム - `WINDOW_UPDATE`(加算する必要あり)

## フレーム
- ストリーム内の各データの最小単位
- 各フレームはストリームIDに紐づき、受信後ストリームIDを元に復元される

### フレームヘッダ
- 各フレームは9バイトの共通ヘッダを持つ

| 要素              | サイズ                 | 概要               |
| -                 | -                      | -                  |
| Length            | 24                     | ペイロードのサイズ |
| Type              | 8                      | フレームの種類     |
| Flags             | 8                      | -                  |
| R                 | 1                      | 予約領域           |
| Stream Identifier | 31                     | ストリーム識別子   |
| Frame Payload     | Lengthで指定された長さ | フレームの実データ |

#### Stream Identifier(ストリームID)
- 各ストリームは一意のストリームIDを持ち、同じIDを持つ一連のフレーム受信時にグループ化されて扱われる
  - 数値0 - 予約ID
  - 奇数ID - クライアントから開始したストリーム
  - 偶数ID - サーバーから開始したストリーム(サーバープッシュ)

### フレームタイプ

| タイプ番号 | タイプ名        | 概要                                             |
| -          | -               | -                                                |
| 0x0        | `DATA`          | リクエスト・レスポンスボディ                     |
| 0x1        | `HEADERS`       | HTTPヘッダi                                      |
| 0x2        | `PRIORITY`      | 依存するストリーム、ストリーム優先度、排他フラグ |
| 0x3        | `RST_STREAM`    | エラーコード(即時終了通知する)                   |
| 0x4        | `SETTINGS`      | 接続に関する設定(ストリームID 0で使用)           |
| 0x5        | `PUSH_PROMISE`  | サーバープッシュ開始の予約                       |
| 0x6        | `PING`          | 応答速度計測用                                   |
| 0x7        | `GOAWAY`        | 最終ストリームID、エラーコード                   |
| 0x8        | `WINDOW_UPDATE` | ウィンドウサイズ                                 |
| 0x9        | `CONTINUATION`  | `HEADERS`・`PUSH_PROMISE`の続きのデータ          |

### `ORIGIN`フレーム
- サーバーはHTTP/2コネクション確立後、ストリームID 0でORIGINフレームを送信する
  - このコネクションでコンテンツを提供できるオリジンのリストが含まれる
    - スキーム/ドメイン名/ポート番号
- クライアントは以降それらのオリジンにリクエストを送信する際、そのコネクションを再利用する
  - その他のオリジンへリクエストを送信する際は新しいコネクションを確立する

## 参照
- [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- [Request and Response](https://youtu.be/0cmXVXMdbs8)
- [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- よくわかるHTTP/2の教科書
- Real World HTTP 第2版
