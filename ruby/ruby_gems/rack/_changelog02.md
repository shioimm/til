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
