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

### クッキー
- サーバー側のデータをクライアント側に保存させるための機構
- 名前=値の形式でヘッダーにてやり取りを行う
- 永続化されていないため、シークレットモードやブラウザ側の操作で削除される場合がある
- 容量は最大4KB
- HTTPSでは暗号化された場合にしか送信できないが、HTTPの場合は平文で送信される

#### クッキーの制約
- Expires / Max-Age属性
  - 有効期限(Max-Ageは秒単位)
- Domain属性
  - クライアントからクッキーを送信する対象のサーバー
    - デフォルトでクッキーを発行したサーバー
- Path属性
  - Domain属性のサーバーのパス
- Secure属性
  - https以外での通信を行わない
  - httpでの通信の場合に警告を発する
- HttpOnly属性
  - JavaScriptエンジンからクッキーを隠す
- SameSite属性
  - Chromeがバージョン51で導入した属性、同じオリジンのドメインに対して送信する

## メソッド
### [GET](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/GET)
- サーバーに対してヘッダーとコンテンツを要求

### [HEAD](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/HEAD)
- サーバーに対してヘッダーを要求

### [POST](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/POST)
- サーバーに対してデータを送信

### [PUT](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/PUT)
- すでにURLが存在するコンテンツの置き換え

### [DELETE](https://developer.mozilla.org/ja/docs/Web/HTTP/Methods/DELETE)
- コンテンツとURLの削除

### 廃止されたメソッド
- LINK
- UNLINK
- CHECKOUT
- CHECKIN
- SHOWMETHOD
- TEXTSEARCH
- SEARCHJUMP
- SEARCH

## パス(URL)
```
https://www.oreilly.co.jp/index.shtml

# スキーマ://ホスト名/パス

# URLの全要素
# スキーマ://ユーザ:パスワード@ホスト名:ポート/パス#フラグメント?クエリ
```
- ポートはスキーマごとにデフォルト値を持つ(httpは80、httpsは443)
- URLの長さはだいたい2000文字くらい(IEは2083文字)

## ステータスコード
- 100番台 -> 処理中
- 200番台 -> 成功
- 300番台 -> サーバーからクライアントへの指示
  - リダイレクトなど -> リダイレクトはLocationヘッダを参照し、ヘッダごと送信し直す
- 400番台 -> クライアント側の異常
- 500番台 -> サーバー側の異常

## ボディ
- ヘッダーの下に空行を入れると、それ以降はボディとして扱われる
- 一通信につき、Content-Length分が指定するバイト数分の一ファイルを扱う

### フォーム
- POST以外のメソッドでボディ(フォーム)を送信することは推奨されない(サーバー側で受け付けない場合がある)
  - そのため、GETにてフォームを送信する場合は、ボディでは無くURLにクエリとして文字列を付与する

#### multipart/form-data
- フォームにてファイルを送信することができるエンコードタイプ
- Content-Typeにboundary(境界文字列・ブラウザごとに異なる)属性が加わる
- ボディ内にヘッダー + 空行 + コンテンツを構成する
  - ヘッダーにContent-Disposition(Content-Typeのようなもの)が加わる

## 認証とセッション
- BASIC認証
- Digest認証
- クッキーによるセッション管理
```
1. クライアントがフォームからIDとPASSを送信(通信時の暗号化が必須)
2. サーバーがIDをPASSを認証し、セッショントークンを発行
3. サーバーがセッショントークンをDBに保存
4. サーバーがクライアントに送信
```

- 署名つきクッキーによるセッション管理
```
1~3までは上記と同じ
4. サーバーがクライアントに対して電子署名済みのセッショントークンを発行
5. クライアントがクッキーを再送した際、サーバーが署名を確認
# サーバー側が署名・確認を行うため、クライアントは鍵を持たない
```

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
