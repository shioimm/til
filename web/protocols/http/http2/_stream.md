# ストリーム、多重化、フレーム
- 参照: [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- 参照: [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- 参照: よくわかるHTTP/2の教科書P76-126

## ストリームの導入
- ストリーム -> クライアント−サーバー間を結ぶ仮想的なコネクション
- 一つのTCPコネクションを再利用し、HTTPリクエストとHTTPレスポンスを複数のストリームによって多重化する
- 複数のリクエスト(ストリーム)を作成し、一回のTCP接続によって送信する
- ブラウザから複数のタブを開いていてもリクエストは一回の接続にまとめられる

### ストリーム -> TCP接続上に作成される複数の仮想的な通信単位
- 一対のリクエストとレスポンスが一ストリームに所属する(一往復したストリームは使われなくなる)
- 一意のID(ストリームID)を持つ
  - コネクション自体を意味するストリームIDは0
  - クライアントから開始したストリームは奇数ID
  - サーバプッシュによってサーバから開始されるストリームは偶数ID
- 各ストリームはそれぞれ独立しているため複数のリクエスト/レスポンスを同時並行的に処理することができる
- ストリームごとに優先度を設定することが可能(PRIORITYフレーム)
- ストリームレベルでフロー制御を行うことが可能(SETTINGSフレーム/WINDOW_UPDATEフレーム)
  - コネクションレベルでのフロー制御も可能
    - 参照: [コネクションレベルとストリームレベル](https://qiita.com/Jxck_/items/622162ad8bcb69fa043d#%E3%83%95%E3%83%AD%E3%83%BC%E5%88%B6%E5%BE%A1%E3%81%AE%E6%96%B9%E6%B3%95)

### フレーム -> データ単位
- フレームは所属しているストリームIDを持つ
- 実際の通信では各フレームがばらばらに送信され、ストリームIDを元に復元される

##### フレームタイプ
- 引用: [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
```
0x0  DATA          リクエスト・レスポンスボディ
0x1  HEADERS       非圧縮または圧縮されたHTTPヘッダー
0x2  PRIORITY      ストリーム優先度変更
0x3  RST_STREAM    ストリーム終了通知
0x4  SETTINGS      接続に関する設定
0x5  PUSH_PROMISE  リソースのプッシュ通知
0x6  PING          接続状況確認
0x7  GOAWAY        接続終了通知
0x8  WINDOW_UPDATE フロー制御ウィンドウの更新
0x9  CONTINUATION  HEADERSフレーム・PUSH_PROMISEフレームのデータ
```
