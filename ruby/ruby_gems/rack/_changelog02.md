# CHANGELOG 2.0.0.rc -> 2.3.0
- 引用: [CHANGELOG](https://github.com/rack/rack/blob/master/CHANGELOG.md)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 2016
### 06-30
#### 2.0.1
[Changed]
- JSONを明示的な依存関係から削除

## 2017
### 05-08
#### 2.0.2
[Added]
- Rack::Session
  - Abstract::SessionHash#fetchを追加
    - デフォルト値のブロックを受け付ける
- Rack::Builder
  - #freeze_appを追加
    - アプリケーションとすべてのミドルウェアをfreezeする

[Changed]
- 偶発的なmutationを避けるため、デフォルトのセッションオプションをfreezeするよう変更
- ハッシュヘッダなしで部分ハイジャックを検出できるように変更
- MiniTest6のマッチャを使用するようにテストをアップデート
- ステータスコード205 Reset ContentレスポンスがContent-Lengthを設定できるように変更
  - RFC 7231にて0に設定することが提案されているため

[Fixed]
- multipart filenamesでnull byteを扱うように修正
- capitalization失敗時の警告を削除
- マルチスレッドサーバのレースコンディションに起因する例外を防止
- docグループの明示的なdepencencyにRDocを追加
- Rack::Multipart::Parserで発生したエラーをbubble upさせずRack::MethodOverrideミドルウェアに追記させるように変更
- すでに削除済みのRack::Utils#bytesizeを使用している箇所をRack::Fileミドルウェアから削除

[Removed]
- deflateエンコーディングのサポートを削除
  - キャッシングのオーバーヘッドを減らすため

[Documentation]
- Rack::Deflaterのexampleを修正

### 05-15
#### 2.0.3
[Changed]
- envの値がASCII 8-bitでエンコードされていることを保証

[Fixed]
- Rack::Session::Abstract::IDからの継承をmixinしている場合の例外の発生を防止

## 2018
### 01-31
#### 2.0.4
[Changed]
- Rack::Lockミドルウェアが元のenvオブジェクトを渡すことを保証
- 大きなファイルをアップロードする際のRack::Multipart::Parserのパフォーマンスを改善
- Rack::Multipart::Parserのバッファサイズを大きくしてパフォーマンスを改善
- 大きなファイルをアップロードする際のRack::Multipart::Parserのメモリ使用量を減少
- ConcurrentRubyのdepencencyをネイティブのQueueに置換

[Fixed]
- Rack::ETagミドルウェアにおいて正しいダイジェストアルゴリズムをrequireするよう修正

[Documentation]
- ホームページのリンクをSSL化

### 04-23
#### 2.0.5
[Fixed]
- 無効なUTF8によって発生したエラーをRack::MethodOverrideミドルウェアに記録するよう修正

### 11-05
#### 2.0.6
[Fixed]
- [CVE-2018-16470]Rack::Multipart::Parserのバッファサイズを小さくし、異常なパーシングを回避
- Rack::ShowExceptionsミドルウェア内に存在しない#accepts_htmlの呼び出しを修正
- [CVE-2018-16471]Rack::Request#schemeにおいてHTTPおよびHTTPSのスキームをホワイトリスト化し、XSS攻撃の可能性を回避

## 2019
### 04-02
#### 2.0.7
[Fixed]
- 仕様に沿わないRack::Multipart::ParserにおけるRack inputに対する#eof?の呼び出しを削除
- 信頼できるプロキシチェーンに転送されたIPアドレスを保存

### 12-08
#### 1.6.12
[Security
- [CVE-2019-16782]セッションIDの検索を狙ったタイミング攻撃を防止
  - BREAKING CHANGE: セッションIDがStringからRack::Session::SessionIdインスタンスへ変更

#### 2.0.8
[Security]
- [CVE-2019-16782]セッションIDの検索を狙ったタイミング攻撃を防止
  - BREAKING CHANGE: セッションIDがStringからRack::Session::SessionIdインスタンスへ変更

## 2020
### 01-10
#### 01-10
[Added]
- SameSite=None Cookieの値をサポート
- ヘッダの追加
  - Trailerヘッダ
- MIMEタイプの追加
  - 動画ストリーミング用のMIMEタイプ
  - WASM用のMIMEタイプ
- ステータスコードの追加
  - Early Hints(103)を追加
  - Too Early(425)を追加
  - Bandwidth Limit Exceeded(509)を追加
- カスタムip_filterのためのメソッドを追加
- rackupにブートタイムプロファイリング機能を追加
- X-Accel-Mappingsヘッダにマルチマッピング対応を追加
- Rack::Deflaterに`sync:false`オプションを追加
- Rack::Builder
  - #freeze_appを追加
    - アプリケーションおよびすべてのミドルウェアインスタンスをfreezeする
- Rack::MockResponseからCookieを抽出するためのAPIを追加

[Changed]
- ミドルウェアからnil値を伝播させないように変更
- レスポンスボディを遅延的に初期化し、必要に応じてバッファリングさせるように変更
- 空のボディにおけるdeflater zlibのバッファエラーを修正
- X-Accel-Redirectをパーセントエンコードされたパスに設定
- multipartをパースする際に不要なバッファを削除
- 初期化時にRack::Staticのルートパスを展開するように変更
- Rack::ShowExceptionsをバイナリデータで動作させるよう変更
- multipartリクエストパースする際、バッファ文字列を使用するよう変更
- config.ruでオプションのUTF-8Byte Order Mark(BOM)をサポート
- オプションのポートでX-Forwarded-Forを扱うように変更
- ExpiresにTime#httpdate形式を使用
  - RFC 7231にて提案
- Rack::Utils
  - ステータスシンボルが無効な場合、500エラーではなく.status_codeが例外を送出するように変更
- Request::SCHEME_WHITELISTをRequest::ALLOWED_SCHEMESにリネーム
- Rack::Multipart
  - Parser.get_filenameが名前に`+`を含むファイルを受け付けるように変更
- デフォルトのハンドラのフォールバックにFalconを追加
- frozen_string_literalsに備え、文字列のmutationを避けるためにコードベースをアップデート
- Rack::MockRequest
  - 入力がオプションで#lengthではなく#sizeに応答するように#env_forを変更
- Rack::FileをRack::Filesにrenameし、非推奨の通知を追加
- Base64のCokieがBase64の“strict encoding”を優先するように変更

[Removed]
- Rack::Response
  - #to_aryを削除
- Rack::Session::Memcacheをdalli gemからRack::Session::Dalliに変更することを推奨化

[Fixed]
- Ruby 2.7の警告を削除

[Documentation]
- Rack::Session::Abstract::IDのexampleを修正
- Rackを実装しているフレームワークのリストにPadrinoを追加
- ヘルプに出力される推奨サーバーオプションからMongrelを削除
- HISTORY.mdとNEWS.mdをCHANGELOG.mdに移動
- CHANGELOGのアップデート

### 01-12
#### 2.1.1
- Rack::ServerのデフォルトミドルウェアからRack::Chunkedを削除
- Rack::Session::SessionId#to_sに依存するコードのサポートをrestore

### 01-27
#### 2.1.2
- denial of serviceに備え複数のファイルのマルチパートパーサーを修正
- Rack::Builder
  - #useのキーワード引数を修正
- Content-Lengthが0の場合、Rack::Deflaterでdeflateをスキップするように変更
- Rack::Session
  - Abstract::SessionHash#transform_keysを削除
- HashクラスとRack::Sessionクラスをラップするto_hashメソッドを追加
- 要求されたセッションIDキーが見つからない場合の処理を追加

### 02-08
#### 2.2.0
[SPEC Changes]
- rack.sessionリクエスト環境エントリはto_hashに対応し、freezeされていないHashを返す必要がある
- リクエスト環境はfreezeできない
- リクエスト環境でASCII以外の文字を持つCGIの値はASCII-8BITエンコーディングを使用しなければならない
- SERVER_NAME、SERVER_PORT、HTTP_HOSTに関するSPEC/lintを改善

[Added]
- rackupが複数の`-r`オプションをサポート
  - 利用時はすべての引数を必要とする
- Rak::Serverが:requireオプションによってrequireするパスの配列をサポート
- Rack::Filesが複数範囲リクエストに対応
- Rack::Multipart::UploadedFileがIOライクなオブジェクトをサポート
  - ファイルシステムを使用する代わりに:filename と:io オプションを使用
- Rack::Multipart::UploadedFileが位置引数に加えて引数キーワード:path,:content_type,:binaryをサポート
- Rack::Staticが一致するファイルがない場合にアプリを呼び出す:cascadeオプションをサポート
- Session::Abstract
  - SessionHash#digの追加
- Rack::Response
  - .[]を追加
    - ステータス、ヘッダ、ボディを使ってインスタンスを作成する
- Rack::MockResponse
  - .[]を追加
    - ステータス、ヘッダ、ボディを使ってインスタンスを作成する
- Rack::Responseの便利なキャッシュとcontent-typeメソッドを追加

[Changed]
- Rack::Request
  - #paramsでEOF Errorをrescueしないように変更
- Rack::Directoryがストリーミングアプローチを使用するように変更
  - 大規模なディレクトリにおけるファーストバイトまでの時間を大幅に改善
- Rack::Directoryがルートディレクトリインデックスにおいて親ディレクトリリンクを含まないように変更
- Rack::QueryParser
  - #parse_nested_queryが新しいクラスにおいて例外を再送出する際、元のバックトレースを使用するよう変更
- Rack::ConditionalGetについて、If-None-MatchヘッダとIf-Modified-Sinceヘッダの両方が提供されている場RFC 7232の順位に従うよう変更
- `.ru`ファイルが、frozen-string-literalのマジックコメントをサポート
- 定数をロードする際、内部ファイルの代わりにautoloadを使用するよう変更
  また'rack/...' だけでなく'rack'を必要とするように変更
- レスポンスがキャッシュされていない場合もRack::ETagがETagを送信し続けるよう変更
- Rack::Request
  - #host_with_portが欠けているポートや空のポートに対するコロンを含まないように変更
- すべてのハンドラがオプションのハッシュ引数の代わりにキーワード引数を使用するように変更
- Rack::Fileによる範囲リクエストの処理において、to_pathをサポートするボディを返さないように変更
  - 範囲リクエストを正しく処理するため
- Rack::Multipart::Generatorについて、
  パスを持つファイルに対してはContent-Length、
  Rack::Multipart::UploadedFileインスタンスがある場合にはContent-Disposition filenameのみをincludeするよう変更
- Rack::Request
  - #ssl?はwssスキーム(secure websockets)においてtrueになるよう変更
- Rack::HeaderHashがデフォルトでメモ化されるよう変更
- Rack::Directoryがルートディレクトリ内でのディレクトリトラバースを許可するように変更
- サーバーの設定によりエンコーディングをソートするよう変更
- Rack::Requestにおけるhost/hostname/authorityの実装をリワーク
  - #hostと#host_with_portは角括弧でフォーマットされたIPv6 アドレスを正しく返すように変更
    - RFC 3986にて定義
- Rack::Builderのパーシングオプションだった最初の`#\`行が非推奨化

[Removed]
- Rack::Directory
  - #pathを削除
    - 常にnilを返しており使用されていなかったため
- Rack::BodyProxy
  - #eachを削除
    - Ruby 1.9.3のバグを回避するためだけに使用されていたため
- Rack::URLMap::INFINITYとURLMap::NEGATIVE_INFINITYを削除
  - 代わりにFloat::INFINITYを使用
- Rack::Fileの非推奨化
- EOLを過ぎたRuby 2.2のサポートを解除
- Rack::Files
  - #response_bodyを削除
    - 実装が壊れていたため
- SERVER_ADDRを削除
  - 元々SPECに含まれていなかったため

[Fixed]
- Rack::Directoryがglobメタ文字を含むルートパスを正しく処理するように修正
- Rack::Cascadeについて、アプリがない状態で初期化された場合、呼び出しごとに新しいレスポンスオブジェクトを使用するよう変更
- Ruby2.7+において、Rack::BodyProxyからボディオブジェクトへキーワード引数を正しく委譲するように修正
- Rack::BodyProxy
  - #methodがボディオブジェクトへ委譲されたメソッドを正しく処理するように修正
- Rack::Request#hostとRack::Request#host_with_portがIPv6アドレスを正しく処理するように修正
- レスポンスハイジャックの際、rack.hijackがvalidなオブジェクトで呼び出されているかどうかをRack::Lintによってチェックするよう修正
- Rack::Response
  - #writeがContent-Lengthを正しくアップデートするよう修正
    - レスポンスボディで初期化された場合
- Rack::CommonLoggerがロギング時にSCRIPT_NAMEを含むよう修正
- Rack::Utils
  - .parse_nested_queryが空のクエリを正しく処理するように修正
    - ハッシュの代わりにparamsクラスの空のインスタンスを使用する
- Rack::Directoryがリンクのパスを正しくエスケープするように修正
- Rack::Request#delete_cookieと、それに関連するRack::Utilsメソッドが
  同じ呼び出しで:domainオプション・:pathオプションを処理するように修正
- Rack::Request#delete_cookieと、それに関連するRack::Utilsメソッドが
  :domainオプション・:pathオプションに完全一致するように修正
- gzippedされたファイルのリクエストが304のレスポンスを持っている場合、
  Rack::Staticがヘッダを追加しないように修正
- Rack::ContentLengthがto_aryに対応していないボディに対しても
  Content-Lengthレスポンスヘッダを設定するように修正
- ThinハンドラがThin::Controllers::Controllerに直接渡されるオプションをサポート
- WEBrickハンドラが:BindAddressオプションを無視しないよう修正
- Rack::ShowExceptionsが無効なPOSTデータを処理するよう修正
- Basic認証において、パスワードが空の場合でもパスワードを要求するように修正
- Rack::LintがSPECごとに、レスポンスが3要素から成る配列であることをチェックするように修正
- WEBrickハンドラ使用時に:SSLEnableオプションをサポート
- バッファリングしている場合、バッファリング後にレスポンスボディを閉じるよう修正
- Cookieをパースする際のデリミタとして`;`のみを許可をするよう修正
- Rack::Utils
  - HeaderHash#clearが名前のマッピングもクリアするよう修正
- nilを渡す`Rack::Files.new`によってRailsの現在のActiveStorage::FileServerの実装が修正された

[Documentation]
- CHANGELOGを更新
- CONTRIBUTINGを追加

### 02-09
#### 2.2.1
[Fixed]
- Rack::Request
  - 空のforwarded_forを扱うため#ipをリワーク

### 02-11
#### 2.2.2
[Fixed]
- Rack::Request
  - 誤っていた#hostの値を修正
- Rack::Handler::Thinの実装をrevert
- "unused variable"の警告を防ぐために二重代入を再び適用
- セッションプールにおけるsame_siteオプションの処理を修正

### Unreleased
#### 2.3.0
[Changed]
- Rack::Request#hostおよびRack::Request#hostname周辺の検証を緩和

[Fixed]
- 最初に委譲を必要とせずにRack::Session::Cookieにアクセスした場合のNoMethodErrorを回避
