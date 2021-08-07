# ストリーム・メッセージ・フレーム
- HTTP/2通信は、任意の数の双方向ストリームを流すことができる単一のTCPコネクション上で行われる
- 各ストリームはメッセージ単位で通信を行い、各メッセージは一つ以上のフレームで構成され、
  各フレームはコネクション上にインターリーブされ、ヘッダ内のストリームIDに従って宛先で再構成される
  - ストリーム - 確立したコネクション内の仮想チャネル
  - メッセージ - 1つ以上のフレームで構成される論理的なHTTPメッセージ
  - フレーム - HTTP/2における通信の最小単位

## ストリーム
- 確立した一つのTCPコネクションの内部に作られる仮想チャネル

## 性質
- ストリームは一意の整数IDを持つ
- 1ストリーム上で1リクエスト・1レスポンスのやりとりが行われる
- ストリームはフレームに付随するフラグによって簡単に作ったり閉じたりすることができる
- ストリーム単位ではTCPハンドシェイクは不要
- ストリームIDの数値とTCPの通信容量が許す限り並列接続を行うことができる

## ストリームID
- 各ストリームは一意のストリームIDを持ち、同じIDを持つ一連のフレーム受信時にグループ化されて扱われる
  - 数値0 - 予約ID
  - 奇数ID - クライアントから開始したストリーム
  - 偶数ID - サーバーから開始したストリーム(サーバープッシュ)

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

### 性質
- 各フレームはヘッダを持ち、最低でもそのフレームが所属するストリームを識別する
- 各フレームは特定のタイプのデータを運ぶ(HTTPヘッダ、ペイロードetc)
- 各フレームはストリームIDに紐づき、受信後ストリームIDを元に再構成される

### フレームヘッダ
- 各フレームは8バイトの共通ヘッダを持つ

| 要素              | サイズ(bit)                | 概要               |
| -                 | -                          | -                  |
| フレーム長        | 24                         | ペイロードのサイズ |
| フレームタイプ    | 8                          | フレームの種類     |
| フラグ            | 8                          | -                  |
| 予約              | 1                          | 予約領域           |
| ストリームID      | 31                         | ストリーム識別子   |
| ペイロード        | フレーム長で指定された長さ | フレームの実データ |

### フレームタイプ

| タイプ番号 | タイプ名        | 概要                                                      |
| -          | -               | -                                                         |
| 0x0        | `DATA`          | HTTPリクエスト・レスポンスボディの送信に使用              |
| 0x1        | `HEADERS`       | HTTPヘッダの送信に使用                                    |
| 0x2        | `PRIORITY`      | 参照されたリソースの優先度指定に使用                      |
| 0x3        | `RST_STREAM`    | ストリームのエラーを通知・終了要求                        |
| 0x4        | `SETTINGS`      | SETTINGSパラメータを通知(ストリームID 0で使用)            |
| 0x5        | `PUSH_PROMISE`  | サーバープッシュの予約を通知                              |
| 0x6        | `PING`          | 応答時間・生存確認に使用                                  |
| 0x7        | `GOAWAY`        | コネクションの終了に使用                                  |
| 0x8        | `WINDOW_UPDATE` | ストリームまたはコネクションごとのフロー制御に使用        |
| 0x9        | `CONTINUATION`  | `HEADERS`フレームに続けてヘッダブロックを送信する際に使用 |

### `ORIGIN`フレーム
- サーバーはHTTP/2コネクション確立後、ストリームID 0でORIGINフレームを送信する
  - `ORIGINフレーム`は当該コネクションでコンテンツを提供できるオリジンのリストを含む
    - `Origin-Entry`: オリジン名(ASCII-Origin: スキーム + ドメイン名 + ポート番号)
- クライアントはORIGINフレームで指定されたオリジンに対してコネクションを再利用できる
  - リストに含まれていないオリジンへリクエストを送信する際は新しいコネクションを確立する必要がある

## 参照
- [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- [Request and Response](https://youtu.be/0cmXVXMdbs8)
- [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- よくわかるHTTP/2の教科書
- Real World HTTP 第2版
- ハイパフォーマンスブラウザネットワーキング
