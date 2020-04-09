# CHANGELOG 2.0.0.rc -> 2.3.0
- 引用: [CHANGELOG](https://github.com/rack/rack/blob/master/CHANGELOG.md)

## 2016
### 06-30
#### 2.0.1
[Changed]
- JSONを明示的な依存関係から削除

## 2017
### 05-08
#### 2.0.2
[Added]
- Session::Abstract::SessionHash#fetchでデフォルト値のブロックを受け付けるように変更
- Builder#freeze_appを追加
  - アプリケーションとすべてのミドルウェアをfreezeする

[Changed]
- デフォルトのセッションオプションをfreeze
  - 偶発的なmutationを避けるため
- ハッシュヘッダなしで部分ハイジャックを検出できるように変更
- MiniTest6のマッチャを使用するようにテストをupgrade
- ステータスコード 205 Reset ContentレスポンスにContent-Lengthを設定できるように変更
  - RFC 7231にて0に設定することが提案されているため

[Fixed]
- multipart filenamesでnull byteを扱うように修正
- miscapitalizedなグローバルによる警告を削除
- マルチスレッドサーバのレースコンディションによる例外を防止
- RDocをdocグループの明示的な依存関係に追加
- Multipart::Parserから発生したエラーをbubble upさせずMethodOverrideミドルウェアに追記させるように変更
- 削除されたUtils#bytesizeの残りの使用をFileミドルウェアから削除

[Removed]
- deflateエンコーディングのサポートを削除
  - キャッシングのオーバーヘッドを減らすため

[Documentation]
- Deflaterのexampleを修正

### 05-15
#### 2.0.3
[Changed]
- envの値がASCII 8-bitでエンコードされていることを保証

[Fixed]
- Session::Abstract::IDからの継承をmixinしているクラスについて例外の発生を防止

## 2018
### 01-31
#### 2.0.4
[Changed]
- Lockミドルウェアが元のenvオブジェクトを渡すことを確認
- 大きなファイルをアップロードする際のMultipart::Parserのパフォーマンスを改善
- Multipart::Parserのバッファサイズを大きくしてパフォーマンスを改善
- 大きなファイルをアップロードする際のMultipart::Parserのメモリ使用量を減少
- ConcurrentRubyの依存関係をネイティブのQueueに置換

[Fixed]
- ETagミドルウェアに正しいダイジェストアルゴリズムをrequire

[Documentation]
- ホームページのリンクをSSL化

### 04-23
#### 2.0.5
[Fixed]
- 無効なUTF8から発生したエラーをMethodOverrideミドルウェアに記録

### 11-05
#### 2.0.6
[Fixed]
- [CVE-2018-16470]Multipart::Parser のバッファサイズを小さくし、pathologicalなパースを回避
- ShowExceptionsミドルウェア内に存在しない#accepts_htmlの呼び出しを修正
- [CVE-2018-16471]Request#schemeでHTTPおよびHTTPSのスキームをホワイトリスト化し、XSS攻撃の可能性を回避

## 2019
### 04-02
#### 2.0.7
[Fixed]
- Multipart::ParserのRack inputに対する#eof?の呼び出しを削除
- 信頼できるプロキシチェーンに転送されたIPアドレスを保存

### 12-08
#### 1.6.12
[Security]
- [CVE-2019-16782]セッションIDのルックアップを狙ったタイミング攻撃を防止
  - BREAKING CHANGE: セッションIDがStringではなくSessionIdインスタンスに変更

#### 2.0.8
[Security]
- [CVE-2019-16782]セッションIDのルックアップを狙ったタイミング攻撃を防止
  - BREAKING CHANGE: セッションIDがStringではなくSessionIdインスタンスに変更

## 2020
### 01-10
#### 01-10
[Added]
- SameSite=None Cookieをサポート
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
- Builder#freeze_appを追加
  - アプリケーションとすべてのミドルウェアインスタンスをfreezeするためのもの
- Rack::MockResponseからCookieを抽出するAPIの追加

[Changed]
- ミドルウェアからnil値を伝播させないように変更
- レスポンスボディを遅延的に初期化し、必要に応じてバッファリング
- 空のボディにおけるdeflater zlibのバッファエラーを修正
- X-Accel-Redirectをパーセントエンコードされたパスに設定
- multipartをパースする際に不要なバッファを削除
- 初期化時にRack::Staticのルートパスを展開するように変更
- ShowExceptionsをバイナリデータで動作させるよう変更
- multipartリクエストを解析する際にバッファ文字列を使用するよう変更
- config.ruでオプションのUTF-8Byte Order Mark(BOM)をサポート
- オプションのポートでX-Forwarded-Forを扱うように変更
- ExpiresにTime#httpdate形式を使用
  - RFC 7231より
- ステータスシンボルが無効な場合、500エラーではなくUtils.status_codeが例外を送出するように変更
- Request::SCHEME_WHITELISTをRequest::ALLOWED_SCHEMESにrename
- Multipart::Parser.get_filenameが名前に+を含むファイルを受け付けるように変更
- デフォルトのハンドラのフォールバックにFalconを追加
- 文字列のmutationを避けるためにコードベースを更新
  - frozen_string_literalsに備えた措置
- MockRequest#env_forを変更
  - 入力がオプションで#lengthではなく#sizeに応答するようになった
- Rack::FileをRack::Filesにrenameし、非推奨の通知を追加
- Base64のCokieがBase64の“strict encoding”を優先するように変更

[Removed]
- Rack::Responseから#to_aryを削除
- Rack::Session::Memcacheをdalli gemからRack::Session::Dalliに変更することを推奨化

[Fixed]
- Ruby 2.7の警告を削除

[Documentation]
- Session::Abstract::IDのexampleを修正
- Rackを実装しているフレームワークのリストにPadrinoを追加
- ヘルプに出力される推奨サーバーオプションからMongrelを削除
- HISTORY.mdとNEWS.mdをCHANGELOG.mdに移動
- CHANGELOGの更新

### 01-12
#### 2.1.1
- Rack::ServerのデフォルトミドルウェアからRack::Chunkedを削除
- SessionId#to_sに依存するコードのサポートをrestore

### 01-27
#### 2.1.2
- 複数のファイルのマルチパートパーサーを修正
  - サービス拒否を防ぐため
- Rack::Builder#useのキーワード引数を修正
- Content-Lengthが0の場合、Rack::Deflaterでデフレーターをスキップするように変更
- SessionHash#transform_keysを削除
- HashクラスとSessionクラスをラップするto_hashメソッドを追加
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
- サーバーが:requireオプションでrequireするパスの配列をサポート
- ファイルはmultipart Rangeリクエストに対応
- Multipart::UploadedFileは、:filename と:io オプションを使用したIOライクなオブジェクトをサポート
  - ファイルシステムを使用する代わり
- Multipart::UploadedFileが位置引数に加えてキーワード引数:path,:content_type,:binaryをサポート
- Staticがアプリを呼び出すための:cascade オプションをサポート
  - 一致するファイルがない場合
- Session::Abstract::SessionHash#digの追加
- スResponse.[]とMockResponse.[]の追加
  - ステータス、ヘッダ、ボディを使ってインスタンスを作成するためのメソッド
- Rack::Responseの便利なキャッシュとcontent-typeメソッドを追加

[Changed]
- Request#paramsでEOF Errorをrescueしないように変更
- ディレクトリがストリーミングアプローチを使用するように変更
  - 大規模なディレクトリのファーストバイトまでの時間を大幅に改善
- ディレクトリがルートディレクトリインデックスに親ディレクトリリンクを含まないように変更
- QueryParser#parse_nested_queryが新しいクラスで例外を再発行する際、元のバックトレースを使用するよう変更
- ConditionalGetについて、If-None-MatchヘッダとIf-Modified-Sinceヘッダの両方が提供されている場合
  RFC 7232の優先順位に従うよう変更
- `.ru`ファイルが、frozen_stringリテラルマジックのコメントに対応するよう変更
- 定数をロードする際、内部ファイルの代わりにautoloadに依存するように変更
  また'rack/...' だけでなく'rack'を必要とするように変更
- レスポンスがキャッシュされていない場合もETagは送信し続けるよう変更
- Request#host_with_portが欠けているポートや空のポートに対するコロンを含まないように変更
- すべてのハンドラがオプションのハッシュ引数の代わりにキーワード引数を使用するように変更
- Rangeリクエストを扱うファイルがto_pathをサポートするボディを返さないように変更
  - Rangeリクエストが正しく処理されるようにするため
- Multipart::Generatorについて、
  パスを持つファイルの場合はContent-Length、
  UploadedFileインスタンスがある場合はContent-Dispositionファイル名のみを含むよう変更
- Request#ssl?はwssスキーム(secure websockets)においてtrueになるよう変更
- Rack::HeaderHashがデフォルトでメモ化されるよう変更
- Rack::Directoryでルートディレクトリ内のディレクトリ移動を許可するように変更
- サーバーの設定によりでエンコーディングをソートするよう変更
- Rack::Requestのhost/hostname/authorityの実装をリワーク
  #hostと#host_with_portは角括弧でフォーマットされた IPv6 アドレスを正しく返すように変更
    - RFC 3986にて定義
- Rack::Builderでの構文解析オプションの最初の#\ 行が非推奨化

[Removed]
- Directory#pathを削除
  - 常にnilを返しており使用されていなかったため
- BodyProxy#eachを削除
  - Ruby 1.9.3のバグを回避するためだけに使用されていたため
- URLMap::INFINITYとURLMap::NEGATIVE_INFINITYを削除
  - 代わりにFloat::INFINITYを使用
- Rack::Fileの非推奨化
- Ruby 2.2のサポートを解除
  - EOLを過ぎているため
- Rack::Files#response_bodyを削除
  - 実装が壊れていたため
- SERVER_ADDRを削除
  - 元々SPECに含まれていなかった

[Fixed]
- ディレクトリがglobメタ文字を含むルートパスを正しく処理するように修正
- Cascadeが呼び出しごとに新しいレスポンスオブジェクトを使用するよう変更
  - アプリがない状態で初期化された場合
- Ruby 2.7+において、BodyProxyがキーワード引数をBodyオブジェクトに正しく委譲するように修正
- BodyProxy#methodがBodyオブジェクトに委譲されたメソッドを正しく処理するように修正
- Request#hostとRequest#host_with_portがIPv6 アドレスを正しく処理するように修正
- レスポンスハイジャックの際、rack.hijackがvalidなオブジェクトで呼び出されているかどうかを
  Lintでチェックするよう修正
- Response#writeがContent-Lengthを正しく更新するよう修正
  -レスポンスボディで初期化された場合
- CommonLoggerがロギング時にSCRIPT_NAMEを含むよう修正
- Utils.parse_nested_queryが空のクエリを正しく処理するように修正
  - ハッシュの代わりにparamsクラスの空のインスタンスを使用する
- ディレクトリがリンクのパスを正しくエスケープするように修正
- Request#delete_cookieと、それに関連するUtilsメソッドが
  同じ呼び出しで:domainオプション・:pathオプションを処理するように修正
- Request#delete_cookieと、それに関連するUtilsメソッドが
  :domainオプション・:pathオプションに完全一致するように修正
- gzippedされたファイルのリクエストが304のレスポンスを持っている場合、
  Staticがヘッダを追加しないように修正
- ContentLengthhがto_aryに応答していないボディに対しても
  Content-Lengthレスポンスヘッダを設定するように修正
- ThinハンドラがThin::Controller::Controllerに直接渡されるオプションをサポート
- WEBrickハンドラが:BindAddress オプションを無視しないように修正
- ShowExceptionsが無効なPOSTデータを処理するよう修正
- Basic認証において、パスワードが空の場合でもパスワードが要求されるように修正
- LintがSPECごとに、レスポンスが3要素から成る配列であることをチェックするように修正
- WEBrickハンドラを使用する際に:SSLEnableオプションを使用できるように修正
- バッファリング時、バッファリングしてからレスポンスボディを閉じるよう修正
- Cookieを解析するときに区切り文字として`;`を受け入れるよう修正
- Utils::HeaderHash#clearは名前のマッピングもクリアするよう修正
- nilを渡す`Rack::Files.new`によってRailsの現在のActiveStorage::FileServerの実装が修正された

[Documentation]
- CHANGELOGを更新
- CONTRIBUTINGを追加

### 02-09
#### 2.2.1
[Fixed]
- Rack::Request#ipをリワーク
  - 空の forwarded_for を扱うため

### 02-11
#### 2.2.2
[Fixed]
- Rack::Request#hostの値が間違っていたため修正
- Rack::Handler::Thinの実装を元に戻すよう修正
- "unused variable"の警告を防ぐために二重代入を再び適用
- セッションプールにおけるsame_siteオプションの扱いを修正

### Unreleased
#### 2.3.0
[Changed]
- Rack::Request#hostおよびRack::Request#hostname周辺の検証を緩和

[Fixed]
- 最初に委譲を必要とせずにRack::Session::Cookieにアクセスした場合のNoMethodErrorを回避
