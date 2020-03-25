# ストリーム、多重化、フレーム
- 参照: [普及が進む「HTTP/2」の仕組みとメリットとは](https://knowledge.sakura.ad.jp/7734/)
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- 参照: [HTTP/2](https://hpbn.co/http2/#binary-framing-layer)
- 参照: よくわかるHTTP/2の教科書P76-126
- HTTP/2において、一つのTCPコネクション内でリクエストとレスポンスを
  並列に扱うための仮想的な概念
- クライアント・サーバーはそれぞれ複数のストリームを作成し、
  実際には一つのTCPコネクション上で直列化して送信する
  - ブラウザから複数のタブを開いていてもリクエストは一つの接続にまとめられる

## ストリーム
- HTTP/2における通信単位
- 1ストリーム上で1リクエスト・1レスポンスのやりとりが行われる

### ストリームID
- 各ストリームは一意のストリームIDを持ち、それぞれ独立して通信が行われる
  - ストリームID 0 -> コネクション自体を意味する
  - ストリームID 奇数 -> クライアントから開始したストリーム
  - ストリームID 偶数 -> サーバーから開始したストリーム(サーバープッシュ)

### ストリームの状態
- 1コネクションにつき使用済みの各ストリームは再利用されなくなる
- ストリームID 0以外のストリームは状態を持つ
  - Idle -> 通信前
  - Open -> 通信可能
  - Close -> 通信終了

### フレームによる制御
- ストリームごとに優先度を設定することが可能 -> PRIORITYフレーム
- ストリームレベルでフロー制御を行うことが可能 -> SETTINGSフレーム/WINDOW_UPDATEフレーム
  - フロー制御 -> 受信可能データ量の調整
  - コネクションレベルでのフロー制御も可能
    - 参照: [コネクションレベルとストリームレベル](https://qiita.com/Jxck_/items/622162ad8bcb69fa043d#%E3%83%95%E3%83%AD%E3%83%BC%E5%88%B6%E5%BE%A1%E3%81%AE%E6%96%B9%E6%B3%95)

## フレーム
- HTTP/2におけるメッセージの最小単位
- 各フレームはストリームIDに紐づき、受信後ストリームIDを元に復元される

### フレームタイプ
- 引用: [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
```
0x0  DATA          リクエスト・レスポンスボディ
0x1  HEADERS       非圧縮または圧縮されたHTTPヘッダー
0x2  PRIORITY      ストリーム優先度変更
0x3  RST_STREAM    ストリーム終了通知
0x4  SETTINGS      接続に関する設定(ストリームID 0で使用)
0x5  PUSH_PROMISE  リソースのプッシュ通知
0x6  PING          接続状況確認
0x7  GOAWAY        接続終了通知(ストリームID 0で使用)
0x8  WINDOW_UPDATE フロー制御ウィンドウの更新
0x9  CONTINUATION  HEADERSフレーム・PUSH_PROMISEフレームのデータ
```
