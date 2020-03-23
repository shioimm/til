# サーバープッシュ機能
- 参照: [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- 参照: [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- 参照: よくわかるHTTP/2の教科書P76-126

## サーバプッシュ機能
- リクエストより先にサーバーからクライアントのキャッシュにデータを加える
- プッシュするコンテンツはWebサーバーのコンフィグに直接記載する、あるいはLinkヘッダ内の記述をみて判断する
- サーバがリクエストを受信後、レスポンスを返す前にPUSH_PROMISEフレームを送信する
  - PUSH_PROMISEフレーム -> レスポンスのストリームの予約と、想定リクエストヘッダを記述
  - 予約したストリームでHTTPレスポンスを送信する
