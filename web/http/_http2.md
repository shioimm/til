# HTTP/2
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- 参照: [HTTP/2 Server Pushとは？(CDN サーバープッシュでWeb高速化）](https://blog.redbox.ne.jp/http2-server-push-cdn.html)
- 参照: [HTTP/2とは](https://www.nic.ad.jp/ja/newsletter/No68/0800.html)
- SPDY = HTTP/2の前身

### 目的
- Webページのリソースの増加(数、サイズ)に伴うパフォーマンス改善
- 「HTTPメッセージのセマンティクスを維持し、パフォーマンスとセキュリティを改善する」

### 仕様
- バイナリ形式のプロトコル
- 一回のTCP接続で複数のリクエストを並行して扱う多重化されたプロトコル
  - 複数のリクエストを作成してから一回の接続によって送信する
  - ブラウザから複数のタブを開いていてもリクエストは一回の接続にまとめられる
  - ストリーム -> TCP接続上に作成される複数の仮想的な通信単位
    - 一対のリクエストとレスポンスが一ストリームに所属する(一往復したストリームは使われなくなる)
    - 一意のID(ストリームID)を持つ
      - コネクション自体を意味するストリームIDは0
      - クライアントから開始したストリームは奇数ID
      - サーバプッシュによってサーバから開始されるストリームは偶数ID
    - フレーム -> データ単位(ex. HEADERSフレーム / DATAフレーム)
      - フレームは所属しているストリームIDを持つ
      - 実際の通信では各フレームがばらばらに送信され、ストリームIDを元に復元される
- HPACK(事前に作成された辞書テーブル)によるヘッダの圧縮
- PRIORITYフレームによるリクエストの優先度制御
- リクエストより先にサーバーからクライアントのキャッシュにデータを加えるサーバープッシュ機能
  - プッシュするコンテンツはWebサーバーのコンフィグに直接記載する、あるいはLinkヘッダ内の記述をみて判断する
- HTTP/2をサポートするブラウザはいずれもSSLを使用している
  - HTTP/2自身はSSLが必須ではない
- 使用するポート番号はHTTP/1.1と同じ
  - HTTP -> 80 / - HTTPS -> 443
- 以下の方法のいずれかでクライアント -> サーバーにHTTP/2での通信開始をネゴシエーションする
  - 1. ALPNを使用する
    - TLS拡張(httpsにて使用される)
  - 2. HTTP/1.1 -> HTTPO/2へのアップグレード
    - httpにて使用される
  - 3. ダイレクトで開始する
    - すでにHTTP/2で接続している場合など

### フレームタイプ
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
