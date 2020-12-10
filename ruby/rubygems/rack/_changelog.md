# CHANGELOG
- 引用: [CHANGELOG](https://github.com/rack/rack/blob/master/CHANGELOG.md)
- 参照: [The new Rack socket hijacking API](https://old.blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 2007-03-03
### 0.1

## 2007-05-16
### 0.2
- HTTP Basic認証
- Cookieセッション
- 静的ファイルハンドラ
- Rack::Request・Rack::Responseの改良
- Rack::ShowStatusを追加
  - エラーメッセージ改良のため
- Campingアダプタのバグ修正
- Railsアダプタの削除

## 2008-02-26
### 0.3
- Rack::Hander
  - LiteSpeedハンドラを追加
  - SCGIハンドラを追加
  - FastCGIハンドラにソケットを開くための:Portと:Fileオプションを追加
- Rack::Session
  - Poolセッションを追加
- Rack::Auth
  - OpenID認証を追加
- Rack::File
  - Last-Modifiedヘッダを追加
- Rack::Builder
  - `#use`がブロックを使用できるように変更
- HTTPステータス201がContent-Typeとボディを含むことができるように変更
- バグ修正
  - 特にCookieに関連するもの

## 2008-08-21
### 0.4
- ミドルウェアの追加
  - Rack::Deflater
- Rack::Auth
  - OpenID認証にruby-openid2が必須化
- Rack::Session
  - Memcacheを追加
- Rack::Handler
  - EventedMongrelハンドラを追加
- rackup
  - `-D`オプションでデーモン化できるように変更
- バグ修正
  - プールセッション、URLMap、スレッドの安全性、tempfileの取り扱いについて
- テストの改善
- RackをGit管理下に移動

## 2009-01-06
### 0.9
- ミドルウェアの追加
  - Rack::ConditionalGet
  - Rack::ContentLength
  - Rack::Deflater
  - Rack::Head
  - Rack::MethodOverride
- Rack::Lint
  - 厳密化、HTTP RFCへの準拠
- Rack::Mime
  - 一般的なMIMEタイプとその拡張を提供するように変更
- Rack::Handler
  - Thinハンドラを追加
- Rack::Utils
  - HeaderHashが大文字小文字を区別しないように変更
- Mongrelヘッダをストリームするように変更
- swiftiplied Mongrelを正式にサポート
- CookieのSecure属性をサポート
- バグ修正
- Rack Core Teamによる管理

## 2009-01-09
### 0.9.1
- Rack::FileとRack::Directoryに対するディレクトリトラバーサル脆弱性を修正

## 2009-04-25
### 1.0.0
- SPEC change
  - Rack::VERSION[1,0]
  - ヘッダ値
    - `\n`区切りの文字列である
  - Content-Lengthが欠落している場合
    - チャンク化された転送エンコーディングを使用する
  - `rack.input`
    - rewindableであり、かつバッファへの読み込みをサポートする
    - そうでない場合、Rack::RewindableInputによってラップする
  - `rack.session`
    - 明示的に指定する
  - レスポンスボディ
    - ファイル名を指定して`#to_path`を呼ぶことができる
    - [NOTE] Ruby1.9による変更
      単一の文字列からなる配列を使用する
- ミドルウェアの追加
  - Rack::Lock
  - Rack::ContentType
- Rack::Reloader
  - rewritten
- Rack::Auth
  - OpenIDメジャーアップデート
- Rack::Response
  - ネストしたパラメータのパースをサポート
  - リダイレクトをサポート
  - CookieのHttpOnly属性をサポート
- Rakefile
  - rewritten
- バグ修正

## 2009-10-18
### 1.0.1
- Bump remainder of `rack.versions`
- ピュアRubyによるFCGI実装をサポート
- フォーム名に"="を含む場合の修正
  - 最初に分割してからコンポーネントをエスケープしないように変更
- 名前にセミコロンを含むfilenameパラメータの取り扱いを修正
- 正規表現をパースするネストしたパラメータにアンカーを追加
  - Stack Overflowを防ぐため
- `<<`の代わりに互換性のあるgzip write API を使うように変更
- `$ ruby -e`でReloaderを実行しても壊れないように修正
- Rack::Handler
  - WEBrickハンドラの:Hostオプションをサポート
- Ruby 1.9関連の修正

## 2010-01-03
### 1.1.0
- SPEC change
  - Rack::Lintを緩和
    - 必要とされる型のサブクラスを許可するため
  - `rack.input`のバイナリモードをドキュメント化
- SPEC define
  - オプションの`rack.logger`の仕様を定義
- Rack::Auth
  - OpenIDをrack-contribに移動
- ミドルウェアの追加
  - Rack::Config
  - Rack::ETag
  - Rack::Runtime
  - Rack::Sendfile
  - Rack::NullLogger
  - Rack::::Logger
- Rack::Files
  - X-Cascadeヘッダをサポート
- Rack::Mime
  - MIMEタイプに`.ogv` `.manifest`を追加
- `PATH_INFO`のスラッシュをsqueezeしないように変更
- Content-Typeを使用してPOSTパラメータをパースするように変更
- Rack::Utils
  - `HTTP_STATUS_CODES`ハッシュのアップデート
  - HeaderHashの最適化
  - `.build_nested_query`を追加
    - `Rack::Utils.parse_nested_query`を補完するため
  - `Multipart.build_multipart`を追加
    - `Rack::Utils::Multipart.parse_multipart`を補完するため
  - Cookieの設定・削除に関するヘルパーメソッドをRack::Responseから移動
    - Rack::Responseの外でも使用できるようにする
- ステータスコード検索ユーティリティの追加
- Rack::Response
  - ステータスコードに対して`#to_i`を呼び出すように変更
- Rack::Request
  - `#user_agent`を追加
  - `#host`がforwardedなホストを把握するように変更
  - `HTTP_HOST`と`SERVER_NAME`の両方が欠落している場合、
    `#host`が空の文字列を返すように変更
  - `#parse_query` / `#parse_multipart`を抽出
    - サブクラスにおいて動作を変更できるようにするため
- Rack::MockRequest
  - ハッシュパラメータを受け付けることを許可するように変更
- rackupをRack::Serverへリファクタリング
- Rack::RewindableInput
  - バイナリエンコーディングを強制するように変更
- RewindableInputを使用しないハンドラに正しい`external_encoding`を設定

## 2010-06-13
### 1.2.0
- Campingアダプタを削除
  - Camping 2.0はrackをそのままサポート
- Rack::Request
  - `.trace?`を追加
  - `.options?`を追加
- Rack::Mime
  - `.webm`を追加
  - `.htc`を追加
- 環境変数
  - `HTTP_X_FORWARDED_FOR`を修正
- 引用符で囲まれた値のパーシングを削除
- その他multipartの修正
- テストをbaconに変更

## 2010-06-15
### 1.2.1
- CGIハンドラをrewindableに変更
- `spec/`を`test/`にリネーム

## 2011-03-13
### 1.1.2 / 1.2.2
- セキュリティ対応
  - Rack::Auth::Digest::MD5
    - 認証がnilを返すと空のパスワードに対して権限が付与されてしまう問題を修正

## 2011-05-22
### 1.2.3
- バグ修正
- Ruby1.8.6対応

### 1.3.0
- パフォーマンス最適化
- multipart
  - 修正 / リファクタ
  - 無限ループ修正
- Rack::Server
  - テストカバレッジの向上
- rackup
  - ハンドラ固有のコマンドラインオプションに対応できるよう変更
- Rack::Request
  - `#params`がPOSTをGETにマージしないように変更
    - 返り値は同じ
- Rack::Response
  - 必要な場合Content-Lengthを削除するように変更
- Rack::Deflater
  - ストリーミングをサポート
- Rack::Handler
  - ロードと検索を改善
- Rack::Session
  - `SecureRandom.hex`を使用するように変更
- `..`を持つファイルを許可し、`..`のパスコンポーネントを許可しないよう変更
- エスケープのために`URI.encode_www_form_component`・コアメソッドを使用するよう変更
- 設定ファイルにおける複数行のコメントを許可
- バグ修正のためクエリパラメータのエスケープを解除
- PATCHメソッドのサポート
- セッションオプションが`env['rack.session.options']`に含まれるように変更
- Cookiesの互換性を保ったままアップデート

## 2011-07-13
### 1.3.1
- Ruby1.9.1をサポート
- JRubyをサポート
- Rack::Utils
  - `.escape`で$KCODEを適切に処理するように変更
- Rack::Lock
  - `method_missing` / `respond_to`の動作を統一
- Rack::Auth::Digest::Request
  - `method_missing` / `respond_to`の動作を統一
- Rack::Multipart::UploadedFile
  - `method_missing` / `respond_to`の動作を統一
- Rack::Session
  - `rack.session`からの受け渡しを有効化
- Rack::CommonLogger
  - ストリーミングレスポンスを正しく処理するように変更
- Rack::MockResponse
  - `body`オブジェクトにおいて`close`を呼び出すように変更
- DOS vectorの修正(MRI stdlib backportより)

## 2011-07-16
### 1.3.2
- Rails、rack-test、Rack::Utils`#escape`が`#to_s`を呼び出すように修正

## 2011-09-16
### 1.2.4
- MRI正規表現エンジンのバグを修正
  - 不正なunicodeによるXSS攻撃を防止

### 1.3.3
- Rack::ShowExceptions
  - クエリパラメータのバグを修正
- Rack::Request
  - `#cookies`が壊れた入力に対して例外を投げないように変更
- MRI正規表現エンジンのバグを修正
  - 不正なunicodeによるXSS攻撃を防止
- Rack::ConditionalGet
  - 壊れたIf-Modified-Sinceヘルパーを扱うように変更

## 2011-10-01
### 1.3.4
- URIにおけるラウンドトリップ問題の修正
- Ruby1.9.3バックポートにおけるセキュリティ修正
- ドキュメントの更新
- Rack::BodyProxyにおいて無限に再帰を引き起こす可能性があったバグを修正
- travis-ciのサポートファイルを追加

## 2011-10-17
### 1.3.5
- Rack1.3.4のバックポートによる警告を修正

## 2011-12-28
### 1.1.3
- セキュリティ対応

### 1.4.0
- Ruby1.8.6のサポートを正式に終了
- config.ruに対する変更
  - 壊れたconfig.ruに対するエラーメッセージを修正
  - config.ruで`run`と`map`を組み合わせることができるように修正
- Rack::ContentType
  - ボディのないレスポンスに対してContent-Typeを設定しないように変更
- Rack::Request
  - `HTTP_X_FORWARDED_SCHEME`のサポートを追加
- Rack::Response
  - Helperがインスタンス変数に依存しないように変更
- Rack::Utils
  - `.build_query`がnilのクエリ値に対して`=`を出力しないように変更
- Rack::Mime
  - MIMEタイプの追加
- Rack::MockRequest
  - HEADメソッドをサポート
- Rack::Directory
  - RFC3986の予約文字を含むファイルをサポート
- Rack::File
  - GETおよびHEADリクエストのみをサポート
- Rack::Server
  - `#start`がRack::Handler`#run`にブロックを渡すように変更
- Rack::Static
  - インデックスオプションをサポート
- rackup
  - デフォルトでMongrelの代わりにThinを使用するように変更
  - インストールされている場合に限る
- ステータスコード205がレスポンスボディを送信しないように変更
- Teapotのステータスコードを追加
- その他バグ修正

## 2012-01-22
### 1.4.1
- ネストされたパラメータの問題を軽減するため、keyspace limit calculationsを変更
- multipartパーシングに対して、ファイルにエスケープされていない`%`が含まれている場合の回避策を追加
- Rack::Response
  - Helperers`#method_not_allowed?`を追加(ステータスコード405)
- Rack::File
  - 不正なディレクトリトラバースに対して404を返すように修正
  - 不正なメソッド(HEAD/GET以外)に対して405を返すように修正
- Rack::Cascade
  - デフォルトで405を捕捉するように変更
- Rack::Session
  - Cookieが`--`を含まない場合に例外を発生させないように変更
  - Cookieのテストの追加
  - Cookieを`secret`または`old_secret`のいずれかで提供できるように変更
- Rack::BodyProxy
  - ブロックの実行を担保
- Rack::Static
  - デフォルトでインデックスファイルの提供を行わないように変更
- Rack.releaseを修正
- テストがset orderに依存しないように変更
- ドキュメントの修正

## 2013-01-06
### 1.1.4
- ユーザーがsession secretをprovideしなかった場合の警告を追加

### 1.2.6
- ユーザーがsession secretをprovideしなかった場合の警告を追加
- 引用符で囲まれていないファイル名に対するパーシングのパフォーマンスを改善

#### 1.3.7
- ユーザーがsession secretをprovideしなかった場合の警告を追加
- 引用符で囲まれていないファイル名に対するパーシングのパフォーマンスを改善
- URIのバックポートをアップデート
- URIのバックポートのバージョンマッチングを修正し、一定の警告を表示しないように変更
- 空の値で正しいパラメータパーシングを行うように変更
- rackup
  - 複数使用を可能にする`--include PATH`オプション
  - pidfileの取り扱い
  - 行番号を正しくレポート
- Rack::Auth
  - Digest::Nonce - 時間制限のあるnoncesによって引き起こされるリクエストループを修正
- Rack::Response
  - `#to_ary`からの再帰ループを防止
- ボディクローズ仕様に準拠した各種ミドルウェアを推奨
- ボディクローズ仕様に対する言語を更新
- ECMAエスケープの互換性問題に関する注意事項を追加
- Rangeヘッダにおける複数範囲のパースを修正
- Windowsにおけるリローダーの修正

### 1.4.2
- ユーザーがsession secretをprovideしなかった場合の警告を追加
- 引用符で囲まれていないファイル名に対するパーシングのパフォーマンスを改善
- URIのバックポートをアップデート
- URIのバックポートのバージョンマッチングを修正し、一定の警告を表示しないように変更
- 空の値で正しいパラメータパーシングを行うように変更
- rackup
  - 複数使用を可能にする`--include PATH`オプション
  - pidfileの取り扱い
  - 行番号を正しくレポート
- Rack::Auth
  - Digest::Nonce - 時間制限のあるnoncesによって引き起こされるリクエストループを修正
- Rack::Response
  - `#to_ary`からの再帰ループを防止
- ボディクローズ仕様に準拠した各種ミドルウェアを推奨
- ボディクローズ仕様に対する言語を更新
- ECMAエスケープの互換性問題に関する注意事項を追加
- Rangeヘッダにおける複数範囲のパースを修正
- Windowsにおけるリローダーの修正
- 空のパラメータキーからのエラーを防止
- Rack::Request
  - PATCHメソッドを追加
- 各種ドキュメントの更新
- session merge semanticsを修正
  - rack-testの修正
- Rack::Static
  - :indexが複数のディレクトリを扱えるように変更
  - sophisticatedな設定のためのヘッダルールをサポート
- Rack::Lint
  - すべてのテストがRack::Lintを利用するように変更
- Rack::File
  - `cache_control`パラメータが非推奨化
    - Rack 1.5.0で削除
- Rack::Directory
  - スクリプト名のエスケープを修正
- Rack::Multipart
  - GeneratorがContent-Lengthヘッダなしでもmultipartパーシングが動作するように変更
- Rack::BodyProxy
  - `#each`を定義
  - C拡張のために利便性を担保
- Rack::Session
  - URIがエスケープされていないCookieが例外を送出しないように変更
- ロゴマークの刷新

## 2013-01-07
### 1.3.8 / 1.4.3
- セキュリティ対応
  - 大規模なmultipart boundaryにおいてバインドされていない読み取りを防止

## 2013-01-13
### 1.1.5 / 1.2.7 / 1.3.9 / 1.4.4
- セキュリティ対応
  - Rack::Auth::AbstractRequestが任意の文字列をシンボル化しないように変更
- 1.3.x系におけるテストケースの誤りを修正

## 2013-01-21
### 1.5.0
- ソケットハイジャック機能の追加
  - アプリケーションがクライアントソケットを乗っ取り、任意の操作を行うためのもの
- Rack::Session
  - Abstract::SessionHashをHashのサブクラスから解除
- Rack::File
  - ヘッダオプションの代わりに使用されていた`cache_control`パラメータの削除
- Rack::Auth
  - シンボルを返していたAbstractRequest`#scheme`が文字列を返すように変更
- Rack::Utils
  - Cookie機能のフォーマットがRFC 2822フォーマットにより期限切れ
- Rack::File
  - デフォルトのMIMEタイプを追加
- rackup
  - `-b 'run Rack::Files.new(".")'` オプションによりコマンドライン設定を提供
- Rack::Deflater
  - レスポンスボディを二重にエンコードしないよう変更
- Rack::Mime
  - Acceptヘッダのマッチングに便利な`#match?`を追加
- Rack::Utils
  - Acceptヘッダの分割を提供`#q_values`を追加
  - Acceptヘッダのヘルパーを提供する`#best_q_match`を追加
  - 古いNetscapeスタイルの時間出力を提供する`#rfc2109`を追加
- Rack::Handler
  - 利用可能なサーバーを見つけるため`.pick`を追加
  - デフォルトサーバーのリストにPumaを追加
    - Webrickより優先される
- 各種ミドルウェアの置き換え時にbodyを正しく`close`するように変更
- Rack::Request
  - GETパラメータのみの場合`#params`が永続化しないように変更
  - 永続的な操作を提供する`#update_param` / `#delete_param`を追加
  - ローカルなUnixドメインソケットに対してtrueを返す`#trusted_proxy?`を追加
- Rack::Response
  - Content-Typeを強制しないように変更
- Rack::Sendfile
  - ローカルマッピングの設定オプションを提供
- HTTPステータスコードを更新
- Ruby1.8.6のサポートを解除

## 2013-01-28
### 1.5.1
- Rack::Lint
  - HijackWrapper`#check_hijack`がSPECの他の部分に準拠
- Rack::Session
  - 互換性のためAbstract::ID::SessionHashにHashライクなメソッドを追加
- 各種ドキュメントの修正

## 2013-02-07
### 1.1.6 / 1.2.8 / 1.13.10
- Rack::Session
  - Cookieの脆弱性CVE-2013-0263対応

#### 1.4.5
- Rack::Session
  - Cookieの脆弱性CVE-2013-0263対応
- Rack::File
  - シンボリックリンクパストラバーサル脆弱性CVE-2013-0262対応

#### 1.5.2
- Rack::Session
  - Cookieの脆弱性CVE-2013-0263対応
  - Railsの互換性を高めるために諸々のメソッドを追加
- Rack::File
  - シンボリックリンクパストラバーサル脆弱性CVE-2013-0262対応
- Rack::Request
  - `#trusted_proxy?`が文字列全体にのみマッチするように変更
- Rack::URLMap
  - Hostヘッダが設定されていない環境におけるホストマッチングを修正
- セキュリティ上の懸念により、Rack 1.6+においてはデフォルトでJSON cookie coderを追加
- pidfileが上書きされる可能性のあったrace conditionを修正
- 各種ドキュメントの追加

## 2014-01-18
### 1.6.0
- Rack::Response
  - Helpers`#unauthorized?`を追加
- Rack::Deflater
  - オプションのハッシュを受け付けるように変更
    - リクエストレベルで圧縮を制御できるようになった
- Rack::Builder
  - アプリケーションのpreloadを行う`#warmup`を追加
- Rack::Request
  - `HTTP_ACCEPT_LANGUAGE`を抽出する`#accept_language`を追加
  - `#port`が複数のX-HTTP-FORWORD-PROTO値をサポート
- rackup
  - Rackサーバーのquiet modeを追加する`--quiet`を追加
- Rack::Etag
  - `etags`をweakとして正しくマーク
- Rack::Utils
  - リクエストが含むことができる最大のパーツ数を設定する`#multipart_part_limit`を追加
- RFC 7231へ準拠しHTTPステータスコードをアップデート
- RFC 2616へ準拠しヘッダ名の検証を緩和
- RFC 7230へ準拠したヘッダを指定するようにSPECをアップデート
- developmentモードにおけるデフォルトのホストをlocalhostに変更
- バグ修正・パフォーマンスの向上

## 2014-05-06
### 1.5.3
- OkJsonのサービス拒否攻撃脆弱性CVE-2014-9490対応
- 1.5系へのバックポートバグ修正

### 1.6.1
- OkJsonのサービス拒否攻撃脆弱性CVE-2014-9490対応
- Rack::Runtime
  - 利用可能であればmonotonicな時間を使用するように変更
- 定数`RACK_MULTIPART_LIMIT`を`RACK_MULTIPART_PART_LIMIT`に変更
  - `RACK_MULTIPART_LIMIT`は非推奨化され、1.7.0 で削除

## 2014-12-04
### 2.0.0.alpha
- ファーストパーティSameSite Cookie
  - ブラウザはCSRF攻撃防止のためサードパーティリクエストからSameSite Cookieを除外する
  - Set-CookieヘッダにおけるSameSite有効化の方法を提供
    - `response.set_cookie 'foo', value: 'bar', same_site: true`または`same_site: :strict`
    - `response.set_cookie 'foo', value: 'bar', same_site: :lax`
  - Sam-site Cookiesの仕様はインターネットドラフトバージョン7に基づく
    - https://tools.ietf.org/html/draft-west-first-party-cookies-07
- ミドルウェアの追加
  - Rack::Event
    - イベントベースのミドルウェア
    - リクエスト/レスポンスのライフサイクルにおいて特定のポイントでの動作のみ監視する
- Rack::Request
  - レスポンスが行われている権限を計算する`#authority`の追加
    - h2プッシュの際に使用する
  - `#add_header`を追加
  - ほとんどのメソッドをRack::Request::Helperモジュールへ移動
    - リクエストオブジェクトから値を取得するためにパブリックAPIを使用
    - ユーザーはRack::Request::Helperを自分のオブジェクトに導入することができるようになり、
      `(get|set|fetch|each)_header`を再実装できる(ex. Proxyオブジェクト)
  - リクエストが複製されたときにenvも複製されるようにす`#initialize_copy`を追加
  - リクエスト固有のデータを操作するためのメソッドを追加
    - CGIパラメータとして設定されたデータや、ユーザが特定のリクエストに関連付けたい任意のデータが含まれる
    - `#has_header?`
    - `#get_header`
    - `#fetch_header`
    - `#each_header`
    - `#set_header`
    - `#delete_header`
- Rack::Response
  - Helpers`#cache_control`および`#cache_control=`を追加
    - レスポンスオブジェクトにCache-Controlヘッダを設定するために使用
  - Helpers`#etag`および`#etag=`を追加
    - レスポンスのetag値を設定するために使用
  - Helpers`#add_header`を追加
    - 複数の値を持つレスポンスヘッダに値を追加
    - Helpersモジュールを含むレスポンスライクなクラスで利用可能
  - レスポンスヘッダを操作するためのメソッドを追加
    レスポンスライクなクラスは次のメソッドを定義していれば
    Rack::Response::Helpersモジュールをincludeすることができる
    - `#has_header?`
    - `#get_header`
    - `#set_header`
    - `#delete_heade`r
- Rack::Session
  - Abstract::IDが非推奨化
    - Abstract::Persistedへの移行を推奨
    - Abstract::Persistedはenvハッシュではなくリクエストオブジェクトを使用
  - セッション情報を調べるためにRack::Requestオブジェクトを使用
  - セッションオブジェクト(Cookieなど)を扱う際、リクエストオブジェクトを一回だけ割り当てる
- リクエストオブジェクトにおけるENVアクセスをモジュールにpullすることを推奨
- ファイルやディレクトリ名に`+`を含むファイルやディレクトリが正しく処理されるように変更
  - Rack::Utils`.unescape_path`を使用しURIパーサーでパスをアンエスケープする
- ポスト数が多すぎるtempfileは自動的にクローズされるように変更
- Rack::Util
  - `.get_byte_ranges`を導入
    - envハッシュに依存せず、渡された`HTTP_RANGE`文字列の値をパースする
  - `.get_byte_ranges`に代わり`.byte_ranbges`が非推奨化
  - "delete" Cookieヘッダを構築するためのメソッドを追加
  - ハッシュをmutatingさせるような副作用に依存せずCookieヘッダを構築できるようになった
- CVE-2015-3225 deepパラメータのパースを防止

## 2016-05-06
### 2.0.0.rc1
- Rack::Session
  - Abstract::IDが非推奨化
    - Abstract::Persistedへの移行を推奨

## 2016-06-30
### 2.0.1
#### [Changed]
- JSONを明示的な依存関係から削除

## 2017-05-08
### 2.0.2
#### [Added]
- Rack::Session
  - Abstract::SessionHash`#fetch`を追加
    - デフォルト値のブロックを受け付ける
- Rack::Builder
  - `#freeze_app`を追加
    - アプリケーションとすべてのミドルウェアをfreezeする

#### [Changed]
- Rack::Session
  - 偶発的なmutationを避けるため、Abstract::Persistedの`DEFAULT_OPTIONS`をfreezeするよう変更
- ハッシュヘッダなしで部分ハイジャックを検出できるように変更
- MiniTest6のマッチャを使用するようにテストをアップデート
- ステータスコード205 Reset ContentレスポンスがContent-Lengthを設定できるように変更
  - RFC 7231にて0に設定することが提案されているため

#### [Fixed]
- Rack::Multipart
  - Parserでnull byteのfilenameを扱うように修正
  - Parserで発生したエラーをbubble upさせずRack::MethodOverrideミドルウェアに追記させるように変更
- Rack::Utils
  - すでに削除済みの`#bytesize`を使用している箇所をRack::Fileミドルウェアから削除
- capitalization失敗時の警告を削除
- マルチスレッドサーバーのレースコンディションに起因する例外を防止
- docグループのdepencencyにRDocを追加

#### [Removed]
- deflateエンコーディングのサポートを削除
  - キャッシングのオーバーヘッドを減らすため

#### [Documentation]
- Rack::Deflaterのexampleを修正

## 2017-05-15
### 2.0.3
#### [Changed]
- envの値がASCII 8-bitでエンコードされていることを保証

#### [Fixed]
- Rack::Session
  - Abstract::IDからの継承をmixinしている場合の例外の発生を防止

## 2018-01-31
### 2.0.4
#### [Changed]
- Rack::Lock
  - オリジナルのenvオブジェクトを渡すことを保証
- Rack::Multipart
  - 大きなファイルをアップロードする際のParserのパフォーマンスを改善
  - 大きなファイルをアップロードする際のParserのメモリ使用量を減少
  - Parserのバッファサイズを大きくしてパフォーマンスを改善
- ConcurrentRubyのdepencencyをネイティブのQueueに置換

#### [Fixed]
- Rack::ETag
  - 正しいダイジェストアルゴリズムをrequireするよう修正

#### [Documentation]
- ホームページのリンクをSSL化

## 2018-04-23
### 2.0.5
#### [Fixed]
- Rack::MethodOverride
  - 無効なUTF8に起因するエラーを壊すのではなく記録するよう修正

## 2018-11-05
### 2.0.6
#### [Fixed]
- Rack::Multipart
  - [CVE-2018-16470]Parserのバッファサイズを小さくし、異常なパーシングを回避
- Rack::ShowExceptions
  - ミドルウェア内に存在しない`#accepts_html`の呼び出しを修正
- Rack::Request
  - [CVE-2018-16471]`#scheme`においてHTTPおよびHTTPSのスキームをホワイトリスト化し、XSS脆弱性に対応

## 2019-04-02
### 2.0.7
#### [Fixed]
- Rack::Multipart
  - Parserにおける仕様に沿わないRack inputに対する`#eof?`の呼び出しを削除
- プロキシチェーンの信頼性のため転送されたIPアドレスを保存

## 2019-12-08
### 1.6.12 / 2.0.8
#### [Security]
- [CVE-2019-16782]セッションIDの検索を狙ったタイミング攻撃を防止
  - セッションIDがStringからRack::Session::SessionIdインスタンスへ変更

## 2020-01-10
### 2.1.0
#### [Added]
- Rack::Utils
  - `SameSite=None`Cookieをサポート
  - ステータスコードの追加
    - 103 Early Hints
    - 425 Too Early
    - 509 Bandwidth Limit Exceeded
- Rack::Chunked
  - Trailerヘッダの追加
- Rack::Mime
  - 動画ストリーミング用のMIMEタイプの追加
  - WASM用MIMEタイプの追加
- Rack::Request
  - カスタム`ip_filter`のためのメソッドを追加
- rackup
  - ブートタイムプロファイリング機能を追加
- Raclk::Sendfile
  - X-Accel-Mappingsヘッダにマルチマッピング対応を追加
- Rack::Deflater
  - `sync: false`オプションを追加
- Rack::Builder
  - アプリケーションおよびすべてのミドルウェアをfreezeする`#freeze_app`を追加
- Rack::MockResponse
  - Cookieを抽出するためのAPIを追加

#### [Changed]
- ミドルウェアからnil値を伝播させないように変更
- レスポンスボディを遅延的に初期化し、必要に応じてバッファリングさせるように変更
- 空のボディにおけるdeflater zlibのバッファエラーを修正
- Rack::Sendfile
  - X-Accel-Redirectヘッダをパーセントエンコードされたパスに設定
- Rack::Multipart
  - multipartをパースする際に不要なバッファを削除
  - multipartリクエストをパースする際、バッファ文字列を使用するよう変更
  - Parser`.get_filename`が名前に`+`を含むファイルを受け付けるように変更
- Rack::Static
  - 初期化時にルートパスを展開するように変更
- Rack::ShowExceptions
  - バイナリデータで動作させるよう変更
- config.ruへの変更
  - オプションのUTF-8Byte Order Mark(BOM)をサポート
- Rack::Request
  - オプションのポートでX-Forwarded-Forを扱うように変更
  - Request::`SCHEME_WHITELIST`をRequest::`ALLOWED_SCHEMES`リネーム
- ExpiresにTime#httpdate形式を使用
  - RFC 7231にて提案
- Rack::Utils
  - ステータスシンボルが無効な場合、500エラーではなく`.status_code`が例外を送出するように変更
- Rack::Handler
  - デフォルトのハンドラのフォールバックにFalconを追加
- `frozen_string_literals`に備え、文字列のmutationを避けるためにコードベースをアップデート
- Rack::MockRequest
  - 入力がオプションで`#length`ではなく`#size`に応答するように`#env_for`を変更
- Rack::File -> Rack::Files
  - renameし、非推奨の通知を追加
- Rack::Session
  - Base64のCookieが"strict encoding"を優先するように変更

#### [Removed]
- Rack::Response
  - `#to_ary`を削除
- Rack::Session
  - Memcacheをdalli gemからRack::Session::Dalliに変更することを推奨

#### [Fixed]
- Ruby 2.7の警告を削除

#### [Documentation]
- Rack::Session
  - Abstract::IDのexampleを修正
- Rackを実装しているフレームワークのリストにPadrinoを追加
- ヘルプに出力される推奨サーバーオプションからMongrelを削除
- HISTORY.mdとNEWS.mdをCHANGELOG.mdに移動
- CHANGELOGのアップデート

## 2020-01-12
### 2.1.1
- Rack::Server
  - デフォルトミドルウェアからRack::Chunkedを削除
- Rack::Session
  - SessionId`#to_s`に依存するコードのサポートをrestore

## 2020-01-27
### 2.1.2
- Rack::Multipart
  - denial of serviceに備え複数のファイルのmultipartパーサーを修正
- Rack::Builder
  - `#use`のキーワード引数を修正
- Rack::Deflater
  - Content-Lengthが0の場合、deflateをスキップするように変更
- Rack::Session
  - Abstract::SessionHash`#transform_keys`を削除
- Rack::Utils
  - HashクラスとRack::Sessionクラスをラップする`#to_hash`メソッドを追加
- 要求されたセッションIDキーが見つからない場合の処理を追加

## 2020-02-08
### 2.2.0
#### [SPEC Changes]
- `rack.session`リクエスト環境エントリは`#to_hash`に対応し、
  freezeされていないHashを返す必要がある
- リクエスト環境はfreezeできない
- リクエスト環境でASCII以外の文字を持つCGIの値はASCII-8BITエンコーディングを使用しなければならない
- `SERVER_NAME` / `SERVER_PORT` / `HTTP_HOST`に関するSPEC/lintを改善

#### [Added]
- rackup
  - 複数の`-r`オプションをサポート
    - 利用時はすべての引数を必要とする
- Rak::Server
  - `:require`オプションによってrequireするパスの配列をサポート
- Rack::Files
  - 複数範囲リクエストに対応
- Rack::Multipart
  - UploadedFileがIOライクなオブジェクトをサポート
  - ファイルシステムを使用する代わりに`:filename` / `:io`オプションを使用
  - UploadedFileが位置引数に加えて引数キーワード`:path` / `:content_type` / `:binary`をサポート
- Rack::Static
  - 一致するファイルがない場合にアプリケーションを呼び出す`:cascade`オプションをサポート
- Rack::Session
  - Abstract::SessionHash`#dig`の追加
- Rack::Response
  - `.[]`を追加
    - ステータス、ヘッダ、ボディを使ってインスタンスを作成する
- Rack::MockResponse
  - `.[]`を追加
    - ステータス、ヘッダ、ボディを使ってインスタンスを作成する
- Rack::Response
  - キャッシュと`#content_type`メソッドを追加

#### [Changed]
- Rack::Request
  - `#params`でEOF Errorをrescueしないように変更
  - `#host_with_port`が欠けているポートや空のポートに対するコロンを含まないように変更
  - `#ssl?`はwssスキーム(secure websockets)においてtrueになるよう変更
  - `#host` / `#hostname` / `#authority`を再実装
    - `#host`と`#host_with_port`は角括弧でフォーマットされたIPv6アドレスを正しく返すように変更
    - RFC 3986にて定義
- Rack::Directory
  - ストリーミングアプローチを使用するように変更
    - 大規模なディレクトリにおけるファーストバイトまでの時間を大幅に改善
  - ルートディレクトリインデックスにおいて親ディレクトリリンクを含まないように変更
  - ルートディレクトリ内でのディレクトリトラバースを許可するように変更
- Rack::QueryParser
  - `#parse_nested_query`が新しいクラスにおいて例外を再送出する際、元のバックトレースを使用するよう変更
- Rack::ConditionalGet
  - If-None-Match / If-Modified-Sinceヘッダの両方が提供されている場合、RFC 7232の順位に従うよう変更
- `.ru`ファイルが、frozen-string-literalのマジックコメントをサポート
- 定数をロードする際、内部ファイルの代わりにautoloadを使用するよう変更
  また'rack/...' だけでなく'rack'を必要とするように変更
- Rack::ETag
  - レスポンスがキャッシュされていない場合もETagを送信し続けるよう変更
- Rack::Handler
  - すべてのハンドラがオプションのハッシュ引数の代わりにキーワード引数を使用するように変更
- Rack::File
  - 範囲リクエストの処理において、`#to_path`をサポートするボディを返さないように変更
  - 範囲リクエストを正しく処理するため
- Rack::Multipart
  - Generatorにおいて、パスを持つファイルの場合はContent-Length、
    UploadedFileインスタンスがある場合はContent-Dispositionのみをincludeするよう変更
- Rack::HeaderHash
  - デフォルトでメモ化されるよう変更
- サーバーの設定によりエンコーディングをソートするよう変更
- Rack::Builder
  - パース時のオプションだった最初の`#\`行が非推奨化

#### [Removed]
- Rack::Directory
  - `#path`を削除
    - 常にnilを返しており使用されていなかったため
- Rack::BodyProxy
  - `#each`を削除
    - Ruby 1.9.3のバグを回避するためだけに使用されていたため
- Rack::URLMap
  - 定数`INFINITY` / `NEGATIVE_INFINITY`を削除
    - 代わりにFloat::INFINITYを使用
- Rack::File
  - 非推奨化
- Rack::Files
  - `#response_body`を削除
    - 実装が壊れていたため
- 定数`SERVER_ADDR`を削除
  - 元々SPECに含まれていなかったため
- EOLを過ぎたRuby 2.2のサポートを解除

#### [Fixed]
- Rack::Directory
  - globメタ文字を含むルートパスを正しく処理するように修正
  - リンクのパスを正しくエスケープするように修正
- Rack::Cascade
  - アプリケーションがない状態で初期化された場合、呼び出しごとに新しいオブジェクトを使用するよう変更
- Rack::BodyProxy
  - Ruby2.7+において、bodyオブジェクトへキーワード引数を正しく委譲するように修正
  - `#method`がbodyオブジェクトへ委譲されたメソッドを正しく処理するように修正
- Rack::Request
  - `#host` / `#host_with_port`がIPv6アドレスを正しく処理するように修正
  - `#delete_cookie`と、それに関連するRack::Utilsメソッドが
    同じ呼び出しで`:domain` / `:path`オプションを処理するように修正
  - `#delete_cookie`と、それに関連するRack::Utilsメソッドが
    `:domain` / `:path`オプションに完全一致するように修正
- Rack::Lint
  - レスポンスハイジャックの際、`rack.hijack`がvalidなオブジェクトで呼び出されているかどうかをチェックするよう修正
  - SPECごとにレスポンスが3要素から成る配列であることをチェックするように修正
- Rack::Response
  - `#write`がContent-Lengthを正しくアップデートするよう修正
    - レスポンスボディで初期化された場合
- Rack::CommonLogger
  - ロギング時に`SCRIPT_NAME`を含むよう修正
- Rack::Utils
  - `.parse_nested_query`が空のクエリを正しく処理するように修正
    - ハッシュの代わりにparamsクラスの空のインスタンスを使用する
  - Cookieをパースする際のデリミタとして`;`のみを許可をするよう修正
  - HeaderHash`#clear`が名前のマッピングもクリアするよう修正
- Rack::Static
  - gzipされたファイルのリクエストが304のレスポンスを持っている場合、ヘッダを追加しないように修正
- Rack::ContentLength
  - `#to_ary`に対応していないボディに対してもContent-Lengthレスポンスヘッダを設定するように修正
- Rack::Handler
  - ThinハンドラがThin::Controllers::Controllerに直接渡されるオプションをサポート
  - WEBrickハンドラが`:BindAddress`オプションを無視しないよう修正
  - WEBrickハンドラ使用時に`:SSLEnable`オプションをサポート
- Rack::ShowExceptions
  - 無効なPOSTデータを処理するよう修正
- Rack::Auth
  - Basic認証において、パスワードが空の場合でもパスワードを要求するように修正
- バッファリングしている場合、バッファリング後にレスポンスボディを閉じるよう修正
- nilを渡す`Rack::Files.new`によってRailsの現在のActiveStorage::FileServerの実装が修正された

#### [Documentation]
- CHANGELOGを更新
- CONTRIBUTINGを追加

## 2020-02-09
### 2.2.1
#### [Fixed]
- Rack::Request
  - 空の`#forwarded_for`を扱うため#ipを再実装

## 2020-02-11
### 2.2.2
#### [Fixed]
- Rack::Request
  - 誤っていた`#host`の値を修正
- Rack::Handler
  - Thinの実装をrevert
- "unused variable"の警告を防ぐために二重代入を再び適用
- Rack::Session
  - Poolにおける`same_site`オプションの処理を修正

### Unreleased
### 2.3.0
#### [Changed]
- Rack::Request
  - `#host` / `#hostname`周辺の検証を緩和

#### [Fixed]
- Rack::Session
  - 最初に委譲を必要とせずにCookieにアクセスした場合のNoMethodErrorを回避
