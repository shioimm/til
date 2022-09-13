# 仕様
## Rackアプリケーション
- RackアプリケーションはcallableRubyオブジェクト
  - `#call`は単一の引数`env`を取る
  - `#call`はステータス、ヘッダ、ボディの3要素からなる配列を返す

### Rack環境
- Rack環境はCGIライクなヘッダを含む、freezeされていないHashインスタンス
- RackアプリケーションはRack環境を自由に変更することができる

### PEP333で指定された環境変数
#### `REQUEST_METHOD`
- リクエストメソッド (必須)

#### `SCRIPT_NAME`
- リクエストURLのパスの最初の部分
- リクエストURLがアプリケーションのルートである場合は空文字列
- 空でない場合は`/`で始まる

#### `PATH_INFO`
- リクエストURLのパスの`SCRIPT_NAME`下の残りの部分
- リクエストURLがアプリケーションのルートであり、最後の`/`がない場合は空文字列

#### `QUERY_STRING`
- リクエストURLのクエリ文字列

#### `SERVER_NAME`
- サーバーのホスト名 (必須)
- `SERVER_NAME` + `SCRIPT_NAME` + `PATH_INFO`でURLが完成する

#### `SERVER_PORT`
- サーバーが動作しているポート (オプション)

#### `HTTP_`変数
- クライアントから送信されたHTTPリクエストヘッダに対応する変数
  - `HTTP_`から始まる変数

### Rack固有の環境変数
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

#### `rack.hijack?`
- サーバーがpartial hijackingをサポートしている場合はtruely

#### `rack.hijack`
- サーバーがfull hijackingをサポートしている場合は
  ハイジャックを実行するために使用される呼び出しに応答するオブジェクト

### オプショナルなRack固有の変数
#### `rack.session`
- リクエストセッションデータを保存するためのHashライクなインターフェース

#### `rack.logger`
- メッセージをロギングするための共通のオブジェクトインターフェース

#### `rack.multipart.buffer_size`
- multipartパーサが読み込みと書き込みに使用するチャンクサイズのヒント (整数値)

#### `rack.multipart.tempfile_factory`
- multipartのフォームフィールドに指定されたファイル名と`content_type`を引数に取る`#call`に応答し、
  `#<<`と`#rewind` (オプション) に応答するIOライクなオブジェクトを返すオブジェクト
- multipartフォームのファイルアップロードフィールド用のtempfileをインスタンス化するために使用される

#### `rack.response_finished`
- レスポンスをクライアントへ送信した後に実行される`callables`の配列
  - `callables`は+env, status, headers, error+の引数で起動される
  - `callables`は登録の逆順で起動される (べき)

## レスポンス
### ステータスコード
- 100以上の整数

### ヘッダ
- freezeされていないハッシュ
- キーは文字列であること
  - `rack.`で始まるヘッダはクライアントに送り返してはいけない (サーバと通信するために使用する)
  - `Status`キーを含んではいけない
  - 印字不可能なASCII、DQUOTE、"(),/:;<=>?@[]{}"を含んではいけない
  - 大文字のASCII文字(A-Z)を含んではいけない
- 値はStringインスタンス、またはStringインスタンスの配列のいずれかであること

#### Content-Type
- ステータスコードが1xx、204、304の場合、Content-Typeヘッダは存在してはいけない

#### Content-Length
- ステータスコードが1xx、204、304の場合、Content-Lengthヘッダは存在してはいけない

### ボディ
- Stringインスタンスの配列、Stringインスタンスを生成するEnumerableなもの、
  Procインスタンス、Fileライクなオブジェクトのいずれか
- `#each`または`#call`に応答できる必要がある
  - `#to_path`や`#to_ary`に応答できることもある (オプション)
  - `#each`に応答するBodyはEnumerable Bodyとみなされる
  - `#call`に応答するBodyはStreaming Bodyとみなされる
  - `#each` / `#call`の両方に応答するBodyはEnumerable Bodyとして扱う
- ボディは消費されるか、返されるかのどちらかでなければならない
  - ボディは`#each` / `#call`のどちらかを任意に呼び出すことで消費される
  - ボディに`#close`が呼び出された場合はボディの生成に関連するリソースを解放する (以降は消費できない)

#### Enumerable Body
- `#each`に応答し、一度だけ呼び出される
- closeした後に呼び出すことは不可能
- String値のみを返す (Body自身はStringのインスタンスではない)

#### Streaming Body
- `#call`に応答し、一度だけ呼び出される
- closeした後に呼び出すことは不可能
- ストリームの引数を取る
  - ストリームは`#read` / `#write` / `#<<` / `#flush`
    / `#close` / `#close_read` / `#close_write` / `#closed`を実装する必要がある

## 参照
- [SPEC.rdoc](https://github.com/rack/rack/blob/master/SPEC.rdoc)
