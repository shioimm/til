# フレーム
- ストリーム内の各データの最小単位

#### 性質
- 各フレームはヘッダを持ち、最低でもそのフレームが所属するストリームを識別する
- 各フレームは特定のタイプのデータを運ぶ(HTTPヘッダ、ペイロードetc)
- 各フレームはストリームIDに紐づき、受信後ストリームIDを元に再構成される

## フレームヘッダ
- 各フレームは8バイトの共通ヘッダを持つ

| 要素              | サイズ(bit)            | 概要                             |
| -                 | -                      | -                                |
| Length            | 24                     | ペイロードのサイズ               |
| Type              | 8                      | フレームタイプ                   |
| Flag              | 8                      | フレームによって使い方が異なる   |
| R                 | 1                      | 予約領域                         |
| Stream Identifier | 31                     | 当該フレームが属するストリームID |
| Frame Payload     | Lengthで指定された長さ | フレームの実データ               |

## フレームタイプ

| 番号 | タイプ名        | 概要                                                                           |
| -    | -               | -                                                                              |
| 0x00 | `DATA`          | HTTPボディを格納                                                               |
| 0x01 | `HEADERS`       | HTTPヘッダを格納(HPACK形式)・連続送信不可                                      |
| 0x02 | `PRIORITY`      | 優先度のWeightとDependencyを格納(任意のフレームの優先度を変更)                 |
| 0x03 | `RST_STREAM`    | ストリームのError Codeを格納(エラー通知・終了要求)                             |
| 0x04 | `SETTINGS`      | SETTINGSパラメータを格納(ストリームID 0で使用)                                 |
| 0x05 | `PUSH_PROMISE`  | サーバープッシュを行うストリームを予約                                         |
| 0x06 | `PING`          | コネクションが維持されていることを確認                                         |
| 0x07 | `GOAWAY`        | ストリームのError Codeを格納(コネクションを切断)                               |
| 0x08 | `WINDOW_UPDATE` | フロー制御において、受信可能量の増加を通知                                     |
| 0x09 | `CONTINUATION`  | HTTPヘッダを格納(HPACK形式)・`HEADERS`に続けてヘッダブロックを送信する際に使用 |

## `ORIGIN`フレーム
- サーバーはHTTP/2コネクション確立後、ストリームID 0でORIGINフレームを送信する
  - `ORIGINフレーム`は当該コネクションでコンテンツを提供できるオリジンのリストを含む
    - `Origin-Entry`: オリジン名(ASCII-Origin: スキーム + ドメイン名 + ポート番号)
- クライアントはORIGINフレームで指定されたオリジンに対してコネクションを再利用できる
  - リストに含まれていないオリジンへリクエストを送信する際は新しいコネクションを確立する必要がある

## 参照
- [普及が進む「http/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- [http の進化](https://developer.mozilla.org/ja/docs/web/http/basics_of_http/evolution_of_http)
- [そろそろ知っておきたいhttp/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- [request and response](https://youtu.be/0cmxvxmdbs8)
- [http/2とは](https://www.nic.ad.jp/ja/newsletter/no68/0800.html)
- [http/2](https://hpbn.co/http2/#binary-framing-layer)
- よくわかるhttp/2の教科書
- real world http 第2版
- ハイパフォーマンスブラウザネットワーキング
