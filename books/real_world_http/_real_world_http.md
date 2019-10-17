# Real World HTTP 歴史とコードに学ぶインターネットとウェブ技術 まとめ
- 渋川よしき 著

## HTTPの基本要素
- メソッドとパス
- ヘッダー
- ボディ
- ステータスコード

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

## HTTP/0.9
- ウェブサイトの情報をサーバーに要求する
  - ホスト名、ポート、パス、検索クエリ
- サーバーから情報をテキストで受け取る

## HTTP/1.0
### 追加された機能
- バージョン
- ステータスコード
  - ニュースグループで使われていた機能が輸入された
- メソッド
  - ニュースグループで使われていた機能が輸入された
- ヘッダー
  - メールシステムで使われていた機能が輸入された
  - リクエストは先頭にメソッド + パスの行が追加される
  - レスポンスは先頭にステータスコードの行が追加される

## HTTP/1.1

## HTTP/2

## セキュリティ

## RESTful API
