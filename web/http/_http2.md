# HTTP/2
- 参照: [HTTP の進化](https://developer.mozilla.org/ja/docs/Web/HTTP/Basics_of_HTTP/Evolution_of_HTTP)
- 参照: [そろそろ知っておきたいHTTP/2の話](https://qiita.com/mogamin3/items/7698ee3336c70a482843)
- 参照: [Request and Response](https://youtu.be/0cmXVXMdbs8)
- SPDY = HTTP/2の前身

### 仕様
- バイナリ形式のプロトコル
- 一回のTCP接続で複数のリクエストを並行して扱う多重化されたプロトコル
  - 複数のリクエストを作成してから一回の接続によって送信する
  - ブラウザから複数のタブを開いていてもリクエストは一回の接続にまとめられる
  - ストリーム -> TCP接続上に作成される複数の仮想的な接続
    - フレーム -> データ単位(ex. HEADERSフレーム / DATAフレーム)
- HPACK(事前に作成された辞書テーブル)によるヘッダの圧縮
- PRIORITYフレームによるリクエストの優先度制御
- リクエストより先にサーバーからクライアントのキャッシュにデータを加えるサーバープッシュ機能
- HTTP/2をサポートするブラウザはいずれもSSLを使用している
  - HTTP/2自身はSSLが必須ではない
