# サーバープッシュ機能
- サーバーがクライアントからリクエストを受け取ることなくサーバーから追加のコンテンツを送信する機能
  - 優先度の高いCSS、JavaScript、画像などの配信に利用される
  - HTTP/2はサーバープッシュにおいてプッシュすべきコンテンツやプッシュ方法について特定のアルゴリズムを指定しておらず、
    プッシュ戦略はサーバーの実装に依存する
- プッシュされたコンテンツはクライアントにキャッシュされ、異なるページで利用可能
- プッシュするコンテンツはWebサーバーのコンフィグに直接記載する
  - あるいはLinkヘッダ内の記述をみて判断する
- HTTP/1.xで行なっていたリソースのインライン化の必要性を排除する


## 仕組み
1. クライアント -> サーバー
  - リクエストを送信
2. サーバー -> クライアント
  - `PUSH_PROMISE`フレームを送信(フレームに記述されているコンテンツをプッシュする意図をクライアントへ伝える)
  - レスポンスを送信
3. クライアントが`PUSH_PROMISE`を受信
  - プッシュされるコンテンツの:authorityを確認
  - コネクションが再利用できない場合は`RST_STREAM`を送信してサーバープッシュを拒否
4. サーバー -> クライアント
  - 予約されたストリームでプッシュするコンテンツを送信
5. クライアントはプッシュされたコンテンツをキャッシュに保存

## `PUSH_PROMISE`(プッシュ予約)フレーム
- サーバープッシュを行うことをクライアントに知らせるためのフレーム
  - Promised Stream ID -> 予約ストリームID(偶数であること)
  - Header Block Fragment -> クライアントから送信されてくると想定したHTTPリクエストヘッダ
- `PUSH_PROMISE`フレームはクライアントからオープンされたストリームでのみ送信することができる

## 参照
- [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- [Request and Response](https://youtu.be/0cmXVXMdbs8)
- [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
- [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- よくわかるHTTP/2の教科書P117-120
- Real World HTTP 第2版
- ハイパフォーマンスブラウザネットワーキング
