# Real World HTTP 歴史とコードに学ぶインターネットとウェブ技術 まとめ
- 渋川よしき 著

## ヘッダー
- `フィールド名:値`という形式で本文の前に付加される
- サーバー-クライアント間での追加情報、指示や命令、お願いなど

### リクエスト
#### [User-Agent](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/User-Agent)
- ブラウザ、OSなどのユーザーエージェント情報を識別する特性文字列

#### [Referer](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Referer)
- 現在のページにリクエストを送る前にリンクを踏んだ直前のページのアドレス

#### [Authorization](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)
- 特別なクライアントにだけ通信を許可する場合、ユーザーエージェントがサーバーから認証を受けるための証明書

### レスポンス
#### [Content-Type](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Type)
- ファイルの種別を示す識別子(MINEタイプ)

#### [Content-Length](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Length)
- サーバーから送信するボディのサイズ(バイト単位)

#### [Content-Encoding](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Content-Encoding)
- ボディが圧縮されている場合、その圧縮形式

#### [Date](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Date)
- メッセージが発信された日時

### その他
- `X-`から始まるヘッダーは各アプリケーションで自由に設定されたもの

### コンテントネゴシエーション
- ヘッダーを利用してサーバーとクライアントがお互いにベストな設定を共有する仕組み

#### ネゴシエーションの対象
- MINEタイプ
  - リクエストヘッダー: Accept
  - レスポンスヘッダー: Content-Type
- 表示言語
  - リクエストヘッダー: Accept-Language
  - レスポンスヘッダー: Content-Type
- 文字のキャラクターセット
  - リクエストヘッダー: Accept-Charset
  - レスポンスヘッダー: Content-Type
- ボディの圧縮
  - リクエストヘッダー: Accept-Encoding
  - レスポンスヘッダー: Content-Encoding
