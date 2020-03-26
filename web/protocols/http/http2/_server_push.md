# サーバープッシュ機能
- 参照: [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- 参照: [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- 参照: よくわかるHTTP/2の教科書P117-120

## 機能概要
- リクエストを受信するより前にサーバーからHTTPレスポンスを送信する機能
- プッシュするコンテンツはWebサーバーのコンフィグに直接記載する、あるいはLinkヘッダ内の記述をみて判断する
- サーバがリクエストを受信後、レスポンスを返す前にPUSH_PROMISEフレームを送信する

## PUSH_PROMISEフレーム
- サーバープッシュを行うことをクライアントに知らせるためのフレーム
  - Promised Stream ID -> 予約ストリームID(偶数であること)
  - Header Block Fragment -> クライアントから送信されてくると想定したHTTPリクエストヘッダ
- PUSH_PROMISEフレームはクライアントからオープンされたストリームでのみ送信することができる

## サーバープッシュの流れ
1. クライアントがリクエストを送信
2. (A)サーバーがPUSH_PROMISEフレームを送信 -> リクエストされるであろうパスと予約したストリームID
   (B)サーバーがレスポンスを送信
3. クライアントがプッシュされるコンテンツの:authorityを確認
   コネクションが再利用できない場合はRST_STREAMを送信してサーバープッシュを拒否
4. サーバーが予約されたストリームでプッシュするコンテンツを送信
5. クライアントはプッシュされたコンテンツをキャッシュに保存
