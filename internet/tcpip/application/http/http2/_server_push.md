# サーバープッシュ機能(HTTP/2)
## TL;DR
- サーバーがクライアントからリクエストを受信する前に、優先度の高いコンテンツを送信する機能
  - CSS、JavaScript、画像etc
- プッシュされたコンテンツはキャッシュに入る
- プッシュされるコンテンツはWebサーバーのコンフィグに直接記載する
  - あるいはLinkヘッダ内の記述をみて判断する

## 仕組み
1. クライアントがリクエストを送信
2. (A)サーバーが`PUSH_PROMISE`フレームを送信 -> リクエストされるであろうパスと予約したストリームID
   (B)サーバーがレスポンスを送信
3. クライアントがプッシュされるコンテンツの:authorityを確認
   コネクションが再利用できない場合は`RST_STREAM`を送信してサーバープッシュを拒否
4. サーバーが予約されたストリームでプッシュするコンテンツを送信
5. クライアントはプッシュされたコンテンツをキャッシュに保存

## `PUSH_PROMISE`フレーム
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
