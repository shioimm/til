# 仕様
- 引用: [SPEC.rdoc](https://github.com/rack/rack/blob/master/SPEC.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## Rackアプリケーション
- Rackアプリケーショは`#call`に応答するRubyオブジェクト(クラスではない)
  - `#call`は単一の引数`env`を取る
  - `#call`はステータス、ヘッダ、ボディの3要素からなる配列を返す

## Rack環境
- Rack環境はCGIライクなヘッダを含む、freezeされていないHashインスタンス
- RackアプリケーションはRack環境を自由に変更することができる

### 一般的な環境変数
#### `REQUEST_METHOD`
- リクエストメソッド(必須)

#### `SCRIPT_NAME`
- リクエストURLのパスの最初の部分
  - アプリケーションがサーバーのルートに対応している場合、
    空の文字列である可能性がある
  - 空でない場合は`/`で始まる

#### `PATH_INFO`
- リクエストURLのパスの残りの部分
  - リクエストURLがアプリケーションのルートをターゲットとし、最後のスラッシュがない場合、
    空の文字列である可能性がある

#### `QUERY_STRING`
- リクエストURLのクエリ文字列

#### `SERVER_NAME`
- サーバーのホスト名(必須)

#### `SERVER_PORT`
- サーバーが動作しているポート(オプション)
  - Integer型

#### `HTTP_ `変数
- クライアントから送信されたHTTPリクエストヘッダに対応する変数
  - `HTTP_`から始まる

### Rack固有の環境変数
#### `rack.version`
- Rack::VERSION
  - Integer型の配列

#### `rack.url_scheme`
- `http`または`https`

#### `rack.input`
- 入力ストリーム
  - 生のHTTP POSTデータを含むIOライクなオブジェクト
  - `ASCII-8BIT`で外部エンコーディングされる
  - バイナリモードでオープンされる
  - `#gets` / `#each` / `#read` / `#rewind`に応答する
    - `#gets` - 引数なしで呼ばれ、文字列を返すかEOFの場合は`nil`を返す
    - `#read` - `IO#read`と同じように動作する
    - `#each` - 引数なしで呼ばれ、文字列のみを生成する
    - `#rewind` - 引数なしで呼ばれ、入力ストリームを最初に巻き戻す
      入力ストリームが巻き戻し可能でない場合、
      入力データを巻き戻し可能なオブジェクトにバッファリングする
- 入力ストリーム上で`#close`を呼んではいけない

#### `rack.errors`
- エラーストリーム
  - `#puts` / `#write` / `#flush` に応答する
    - `#puts` - `#to_s`に応答する単一の引数で呼ぶ
    - `#write` - Stringオブジェクトである単一の引数で呼ぶ
    - `#flush` - 引数なしで呼ばれ、エラーを確実に表示させる
- エラーストリーム上で`#close`を呼んではいけない

#### `rack.multithread`
- アプリケーションオブジェクトが同じプロセス内の別のスレッドから
  同時に呼び出される可能性がある場合は`true`、そうでない場合は`false`

#### `rack.multiprocess`
- 等価なアプリケーションオブジェクトが他のプロセスから
  同時に呼び出される可能性がある場合は`true`、そうでない場合は`false`

#### `rack.run_once`
- アプリケーションがプロセスを実行中に一度だけサーバーが起動されることを
  期待している場合は`true`、そうでない場合は`false`
  - 通常、CGIベースのサーバーに対してのみ`true`となる

#### `rack.hijack?`
- サーバーがHijacking APIをサポートしている場合は`true`、そうでない場合は`false`
  - Hijacking APIはリクエストのハイジャックおよびレスポンスのハイジャックを行う

#### `rack.hijack`
- `rack.hijack?`が`true`の場合、`#call`に応答するオブジェクトを返す
  - 割り当てられるIOを返す
  - `rack.hijack_io`を使う前に少なくとも一度は呼び出す必要がある
  - Rack環境に設定するだけでなく、必要に応じて`#call`が`rack.hijack_io`を返すことが推奨される
- `rack.hijack?`が`false`の場合、設定されるべきではない

#### `rack.hijack_io`
- `rack.hijack?`が`true`かつ`rack.hijack`が`#call`を受信した場合
  IOライクなオブジェクトを返す
  - `#read` / `#write` / `#read_nonblock` / `#write_nonblock` / `#flush`
    / `#close` / `#close_read` / `#close_write` / `#closed?`に応答する
    - いずれのメソッドもIOオブジェクトまたはSocketオブジェクトのセマンティクスに一致する必要がある
  - サポートされている場合はIO::WaitReadableとIO::WaitWritable APIによって提供されることが推奨
- `rack.hijack?`が`false`の場合、設定されるべきではない

### オプショナルなRack固有の変数
#### `rack.session`
- リクエストセッションデータを保存するためのHashライクなインターフェース

#### `rack.logger`
- メッセージをロギングするための共通のオブジェクトインターフェース

#### `rack.multipart.buffer_size`
- 読み出しと書き込みに使用するチャンクサイズを指定するためのヒント
  - Integer型

#### `rack.multipart.tempfile_factory`
- `#call`に応答するオブジェクト
  - multipartフォームフィールドに与えられたファイル名と
    `content_type`の2つの引数を持つ、
  - `#<<と`オプションで`#rewind`に応答するIOライクなオブジェクトを返す
  - multipartフォームのファイルアップロードフィールド用のtempfileインスタンスを作成するために使用される

### `rack.hijack`に関する規約
- ミドルウェアはレスポンス全体を処理している場合を除き、`rack.hijack`を使用すべきではない
- ミドルウェアはレスポンスパターンのIOオブジェクトをラップしても良い
- ミドルウェアはリクエストパターンのIOオブジェクトをラップすべきではない
  - リクエストパターンはハイジャッカーに生のtcpを提供することを目的としている

## レスポンス
### ステータスコード
- 100以上の整数

### ヘッダ
- `#each`に応答し、キーと値を生成する
- キーは文字列である必要がある
- `rack.`で始まるヘッダは、サーバーと通信するためのものであり、
  クライアントに送り返してはいけない
- ヘッダには`Status`キーを含んではいけない
- ヘッダはRFC7230トークン仕様に準拠している必要がある

#### Content-Type
- ステータスコードが1xx、204、304の場合、Content-Typeヘッダは存在してはいけない

#### Content-Length
- ステータスコードが1xx、204、304の場合、Content-Lengthヘッダは存在してはいけない

### ボディ
- `#each`に応答し、Stringの値のみを生成する
- ボディが`#close`に応答した場合、反復処理の後に呼び出される
  - ボディがアクションの後にミドルウェアに置き換えられた場合、元のボディを先に閉じる必要がある
- ボディが`#to_path`に応答した場合、`#each`の呼び出しによって生成された内容と
  同じ内容のファイルの位置を示すStringを返す必要がある
- ボディは通常、文字列の配列、アプリケーションのインスタンスそのもの、あるいはFileライクなオブジェクト
