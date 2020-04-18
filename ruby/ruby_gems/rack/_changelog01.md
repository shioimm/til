# CHANGELOG 0.1.0 -> 2.0.0.rc
- 引用: [CHANGELOG](https://github.com/rack/rack/blob/master/CHANGELOG.md)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 2007
### 03-03
#### 0.1

### 05-16
#### 0.2
- HTTP Basic認証
- Cookieセッション
- 静的ファイルハンドラ
- Rack::Request・Rack::Responseの改良
- Rack::ShowStatusを追加
  - エラーメッセージ改良のため
- Campingアダプタのバグ修正
- Railsアダプタの削除

## 2008
### 02-26
#### 0.3
- Rack::Hander
  - LiteSpeedハンドラを追加
  - SCGIハンドラを追加
- Rack::Session
  - Poolセッションを追加
- Rack::Auth
  - OpenID認証を追加
- FastCGIソケットを開く:Portと:Fileオプションの追加
- Rack::FileにLast-Modifiedヘッダを追加
- Rack::Builder#useがブロックを使用できるように変更
- HTTPステータス201がContent-Typeとボディを含むことができるように変更
- その他バグ修正
  - 特にCookieに関連するもの

### 08-21
#### 0.4
- ミドルウェアの追加
  - Rack::Deflaterミドルウェア
- Rack::Auth
  - OpenID認証にruby-openid2が必須化
- Rack::Session
  - Memcacheセッションを追加
- Rack::Handler
  - EventedMongrelを明示的に追加
- rackupの改良
  - developmentモードでRack::Reloaderがロードされないように変更
  - `-D`オプションでデーモン化できるように変更
- その他バグ修正
  - 特にプールセッション、URLMap、スレッドの安全性、tempfileの取り扱いについて
- その他テストの改善
- RackをGit管理下に移動

## 2009
### 01-06
#### 0.9
- Rack::Lintの厳密化およびRFCへの準拠
- ミドルウェアの追加
  - Rack::ConditionalGetミドルウェア
  - Rack::ContentLengthミドルウェア
  - Rack::Deflaterミドルウェア
  - Rack::Headミドルウェア
  - Rack::MethodOverrideミドルウェア
- Rack::Mimeが一般的なMIMEタイプとその拡張を提供するように変更
- Mongrelヘッダをストリーム化
- Rack::Handler
  - Thinハンドラを追加
- swiftiplied Mongrelを正式にサポート
- Cookieのセキュアオプションをサポート
- HeaderHashが大文字小文字を区別しないように変更
- その他バグ修正、改善

### 01-09
#### 0.9.1
- Rack::FileとRack::Directoryに対するディレクトリトラバーサルの悪用を修正

### 04-25
#### 1.0.0
- SPEC change
  - Rack::VERSION[1,0]
  - ヘッダの値が`\n`区切りの文字列であることを規定
  - Content-Lengthが欠落している場合、チャンク化された転送エンコーディングを使用するように規定
  - `rack.input`に関する規定
    - rewindableであり、かつバッファへの読み込みをサポートすることを規定
    - そうでない場合、Rack::RewindableInputによってラップする
  - `rack.session`を明示するように規定
  - ボディはファイル名を指定して#to_pathが呼べることを規定
  - [NOTE]ボディに関して、文字列オブジェクトではなく、ひとつの文字列オブジェクトからなる配列を使用することを規定
    - Ruby1.9でStringが壊れたため
- ミドルウェアの追加
  - Rack::Lockミドルウェア
  - Rack::ContentTypeミドルウェア
- Rack::Reloaderの書き換え
- Rack::Auth
  - OpenIDのメジャーアップデート
- Rack::Response
  - ネストしたパラメータのパースをサポート
  - リダイレクトをサポート
  - CookieのHttpOnlyオプションをサポート
- Rakefileの書き換え
- その他バグ修正、改善

### 10-18
#### 1.0.1
- `rack.version`へ変更されていなかった箇所を修正
- ピュアRubyによるFCGI実装をサポート
- フォーム名に"="を含む場合の修正
  - 最初に分割してからコンポーネントをエスケープしないように変更
- 名前にセミコロンを含むfilenameパラメータの取り扱いを修正
- 正規表現をパースするネストしたパラメータにアンカーを追加
  - Stack Overflowを防ぐため
- `<<`の代わりに互換性のあるgzip write API を使うように変更
- `$ ruby -e`でReloaderを実行しても壊れないように修正
- WEBrickの:Hostオプションをサポート
- Ruby 1.9関連の修正

## 2010
### 01-03
#### 1.1.0
- SPEC change
  - Rack::Lintを緩和
    - 必要とされる型のサブクラスを許可するため
  - `rack.input`のバイナリモードをドキュメント化
- SPEC define
  - オプショナルな`rack.logger`の仕様を定義
- Rack::Auth
  - OpenIDをrack-contribに移動
- ファイルサーバがX-Cascadeヘッダをサポート
- ミドルウェアの導入
  - Rack::Configミドルウェア
  - Rack::ETagミドルウェア
  - Rack::Runtimeミドルウェア
  - Rack::Sendfileミドルウェア
- ミドルウェアの追加
  - Rack::NullLoggerミドルウェア
  - Rack::::Loggerミドルウェア
- MIMEタイプに`.ogv` `.manifest`を追加
- PATH_INFOのスラッシュをsqueezeしないように変更
- Content-TypeによってPOSTパラメータをパースするように変更
- Rack::Utils::HTTP_STATUS_CODESハッシュのアップデート
- ステータスコード検索ユーティリティの追加
- Rack::Responseがステータスコードに対して#to_iを呼び出すように変更
- Rack::Request
  - #user_agentを追加
  - #hostがforwardedなホストを把握するように変更
  - #hostが空の文字列を返すように変更
    - HTTP_HOSTとSERVER_NAMEの両方が欠落している場合
- Rack::MockRequestがハッシュパラメータを受け付けることを許可するように変更
- rackupをRack::Serverに対してリファクタリング
- Rack::Utils
  - HeaderHashの最適化
  - .build_nested_queryを追加
    - Rack::Utils.parse_nested_queryを補完するため
  - Multipart.build_multipartを追加
    - Rack::Utils::Multipart.parse_multipartを補完するため
  - Cookieヘルパーのsetとdeleteを抽出
    - Rack::Responseの外で使用できるようにするため
- Rack::Request
  - #parse_queryと#parse_multipartを抽出
    - サブクラスにおいて動作を変更できるようにするため
- Rack::RewindableInputにおいてバイナリエンコーディングを強制するように変更
- RewindableInputを使用しないハンドラに正しいexternal_encodingを設定

### 06-13
#### 1.2.0
- Campingアダプタを削除
  - Camping 2.0はrackをそのままサポート
- 引用符で囲まれた値のパーシングを削除
- メソッドの追加
- Rack::Request
  - .trace?を追加
  - .options?を追加
- MIMEタイプに`.webm` `.htc`を追加
- HTTP_X_FORWARDED_FORを修正
- その他multipartの修正
- テストをbaconに変更

### 06-15
#### 1.2.1
- CGIハンドラをrewindableに変更
- `spec/`を`test/`にリネーム

## 2011
### 03-13
#### 1.1.2
- セキュリティ対応
  - Rack::Auth::Digest::MD5
    - 認証がnilを返すと空のパスワードに対して権限が付与されてしまう問題を修正

#### 1.2.2
- セキュリティ対応
  - Rack::Auth::Digest::MD5
    - 認証がnilを返すと空のパスワードに対しても権限が付与されてしまう問題を修正

### 05-22
#### 1.2.3
- バグ修正
- Ruby1.8.6対応

#### 1.3.0
- パフォーマンス最適化
- multipartの修正
- multipartリファクタ
- multipartの無限ループ修正
- Rack::Serverのテストカバレッジ向上
- `..`を持つファイルを許可し、`..`のパスコンポーネントを許可しないよう変更
- rackupがハンドラ固有のコマンドラインオプションに対応できるよう変更
- Rack::Request
  - #paramsがPOSTをGETにマージしないように変更
    - 返り値は同じ
- エスケープのためにURI.encode_www_form_component・コアメソッドを使用するよう変更
- 設定ファイルにおける複数行のコメントを許可
- バグ修正のためクエリパラメータのエスケープを解除
- Rack::Responseは必要な場合Content-Lengthを削除するように変更
- Rack::Deflaterがストリーミングをサポート
- Rack::Handlerのロードと検索を改善
- PATCHメソッドのサポート
- セッションオプションが`env['rack.session.options']`に含まれるように変更
- Cookiesの互換性を保ったままアップデート
- Rack::SessionミドルウェアでSecureRandom.hexを使用するように変更

### 07-13
#### 1.3.1
- Ruby1.9.1をサポート
- JRubyをサポート
- Rack::Utils
  - .escapeで$KCODEを適切に処理するように変更
- 以下におけるmethod_missing/respond_toの動作を統一
  - Rack::Lock
  - Rack::Auth::Digest::Request
  - Rack::Multipart::UploadedFile
- rack.sessionからRack::Sessionミドルウェアに対する受け渡しを有効化
- Rack::CommonLoggerがストリーミングレスポンスを正しく処理するように変更
- Rack::MockResponseがbodyオブジェクトにおいてcloseを呼び出すように変更
- DOS vectorの修正(MRI stdlib backportより)

### 07-16
#### 1.3.2
- Rails、rack-test、Rack::Utils#escapeが#to__sを呼び出すように修正

### 09-16
#### 1.2.4
- MRI正規表現エンジンのバグを修正
  - 不正なunicodeによるXSS攻撃を防止

#### 1.3.3
- Rack::ShowExceptionsのクエリパラメータが壊れていたバグを修正
- Rack::Request
  - #cookiesが壊れた入力に対して例外を投げるように変更
- MRI正規表現エンジンのバグを修正
  - 不正なunicodeによるXSS攻撃を防止
- Rack::ConditionalGetが壊れたIf-Modified-Sinceヘルパーを扱うように変更

### 10-01
#### 1.3.4
- URIにおけるラウンドトリップ問題の修正
- Ruby1.9.3バックポートにおけるセキュリティ修正
- ドキュメントの更新
- Rack::BodyProxyにおいて無限に再帰を引き起こす可能性があったバグを修正
- travis-ciのサポートファイルを追加

### 10-17
#### 1.3.5
- Rack1.3.4のバックポートによる警告を修正

### 12-28
#### 1.1.3
- セキュリティ対応

#### 1.4.0
- Ruby1.8.6のサポートを正式に終了
  - 通らないテストは残っている
- config.ruに対する修正
  - 壊れたconfig.ruに対するエラーメッセージを修正
  - config.ruで`run`と`map`を組み合わせることができるように修正
- Rack::ContentTypeがボディのないレスポンスに対してContent-Typeを設定しないように変更
- ステータスコード205がレスポンスボディを送信しないように変更
- Rack::Response
  - Helperがインスタンス変数に依存しないように変更
- Rack::Utils
  - .build_queryがnilのクエリ値に対して'='を出力しないように変更
- MIMEタイプの追加
- Rack::MockRequestがHEADメソッドをサポート
- Rack::DirectoryがRFC3986の予約語を含むファイルをサポート
- Rack::FileがGETおよびHEADリクエストのみをサポート
- Rack::Server
  - #startがRack::Handler#runにブロックを渡すように変更
- Rack::Staticがインデックスオプションをサポート
- Teapotのステータスコードを追加
- rackupでデフォルトでMongrelの代わりにThinを使用するように変更
  - インストールされている場合に限る
- HTTP_X_FORWARDED_SCHEMEのサポートを追加
- その他バグ修正

## 2012
### 01-22
#### 1.4.1
- ネストされたパラメータの問題を軽減するため、keyspace limit calculationsを変更
- multipartパーシングに対して、ファイルにエスケープされていない`%`が含まれている場合の回避策を追加
- Rack::Response
  - Helperers#method_not_allowed?を追加(ステータスコード405)
- Rack::Fileが不正なディレクトリトラバースに対して404を返すように修正
- Rack::Fileが不正なメソッド(HEAD/GET以外)に対して405を返すように修正
- Rack::Cascadeがデフォルトで405を捕捉するように変更
- Cookieが`--`を含まない場合に例外を発生させないように変更
- ドキュメントの修正
- Rack::BodyProxyにおけるブロックの実行を担保
- Cookieとsecretに関するテストの追加
- Rack::Session
  - Cookieをsecretまたはold_secretのいずれかで提供できるように変更
- テストがset orderに依存しないように変更
- Rack::Staticがデフォルトでインデックスファイルの提供を行わないように変更
- Rack.releaseを修正

## 2013
### 01-06
#### 1.1.4
- ユーザーがsession secretをprovideしなかった場合の警告を追加

#### 1.2.6
- ユーザーがsession secretをprovideしなかった場合の警告を追加
- 引用符で囲まれていないファイル名に対するパーシングのパフォーマンスを改善

#### 1.3.7
- ユーザーがsession secretをprovideしなかった場合の警告を追加
- 引用符で囲まれていないファイル名に対するパーシングのパフォーマンスを改善
- URIのバックポートをアップデート
- URIのバックポートのバージョンマッチングを修正し、一定の警告を表示しないように変更
- 空の値で正しいパラメータパーシングを行うように変更
- rackupの修正・変更
  - 複数使用を可能にする`--include PATH`オプション
  - pidfileの取り扱い
  - 行番号を正しくレポート
- 時間制限のあるnon-stale noncesによって引き起こされるリクエストループを修正
- Windowsにおけるリローダーの修正
- Rack::Response
  - #to_aryからの再帰ループを防止
- ボディクローズ仕様に準拠した各種ミドルウェアを推奨
- ボディクローズ仕様に対する言語を更新
- ECMAエスケープの互換性問題に関する注意事項を追加
- Rangeヘッダにおける複数範囲のパースを修正

#### 1.4.2
- ユーザーがsession secretをprovideしなかった場合の警告を追加
- 引用符で囲まれていないファイル名に対するパーシングのパフォーマンスを改善
- URIのバックポートをアップデート
- URIのバックポートのバージョンマッチングを修正し、一定の警告を表示しないように変更
- 空の値で正しいパラメータパーシングを行うように変更
- rackupの修正・変更
  - 複数使用を可能にする`--include PATH`オプション
  - pidfileの取り扱い
  - 行番号を正しくレポート
- 時間制限のあるnon-stale noncesによって引き起こされるリクエストループを修正
- Windowsにおけるリローダーの修正
- Rack::Response
  - #to_aryからの再帰ループを防止
- ボディクローズ仕様に準拠した各種ミドルウェアを推奨
- ボディクローズ仕様に対する言語を更新
- ECMAエスケープの互換性問題に関する注意事項を追加
- Rangeヘッダにおける複数範囲のパースを修正
- 空のパラメータキーからのエラーを防止
- Rack::RequestにPATCHメソッドを追加
- 各種ドキュメントの更新
- session merge semanticsを修正
  - rack-testの修正
- Rack::Static :indexが複数のディレクトリを扱えるように変更
- すべてのテストがRack::Lintを利用するように変更
- Rack::Fileにおけるcache_controlパラメータが非推奨化
  - Rack 1.5.0で削除
- Rack::Directoryスクリプト名のエスケープを修正
- Rack::Staticがsophisticatedな設定のためのヘッダルールをサポート
- Content-Lengthヘッダなしでもmultipartパーシングが動作するように変更
- ロゴマークの刷新
- Rack::BodyProxyが#eachを明示的に定義
  - C拡張のために利便性を担保
- URIがエスケープされていないCookieが例外を送出しないように変更

### 01-07
#### 1.3.8
- セキュリティ対応
  - 大規模なmultipart boundaryにおいてバインドされていない読み取りを防止

#### 1.4.3
- セキュリティ対応
  - 大規模なmultipart boundaryにおいてバインドされていない読み取りを防止

### 01-13
#### 1.1.5
- セキュリティ対応
  - Rack::Auth::AbstractRequestが任意の文字列をシンボル化しないように変更
- 1.3.x系におけるテストケースの誤りを修正

#### 1.2.7
- セキュリティ対応
  - Rack::Auth::AbstractRequestが任意の文字列をシンボル化しないように変更
- 1.3.x系におけるテストケースの誤りを修正

#### 1.3.9
- セキュリティ対応
  - Rack::Auth::AbstractRequestが任意の文字列をシンボル化しないように変更
- 1.3.x系におけるテストケースの誤りを修正

#### 1.4.4
- セキュリティ対応
  - Rack::Auth::AbstractRequestが任意の文字列をシンボル化しないように変更
- 1.3.x系におけるテストケースの誤りを修正

### 01-21
#### 1.5.0
- ハイジャックSPECの導入
  - レスポンス前後のハイジャックを実現するため
- Rack::Session
  - Abstract::SessionHashをHashのサブクラスから解除
- ヘッダオプションの代わりに使用されていたRack::File cache_controlパラメータの削除
- Rack::Auth
  - シンボルを返していたAbstractRequest#schemeが文字列を返すように変更
- Rack::UtilsのCookie機能のフォーマットがRFC 2822 フォーマットにより期限切れ
- Rack::FileにデフォルトのMIMEタイプを追加
- rackup -b 'run Rack::Files.new(".")' オプションによりコマンドライン設定を提供
- Rack::Deflaterがレスポンスボディを二重にエンコードしないよう変更
- Rack::Mime
  - Acceptヘッダのマッチングに便利なmatch?を追加
- Rack::Utils
  - Acceptヘッダの分割を提供#q_valuesを追加
  - Acceptヘッダのヘルパーを提供する#best_q_matchを追加
- Rack::Handler
  - 利用可能なサーバーを見つけるため.pickの追加
- デフォルトサーバーのリストにPumaを追加
  - Webrickより優先される
- 各種ミドルウェアの置き換え時にbodyを正しく閉じるように変更
- Rack::Request
  - GETパラメータのみの場合#paramsが永続化しないように変更
  - 永続的な操作を提供する#update_param / #delete_paramを追加
  - local unix socketsに対してtrueを返す#trusted_proxy?を追加
- Rack::ResponseがContent-Type を強制しないように変更
- Rack::Sendfileがローカルマッピングの設定オプションを提供
- Rack::Utils
  - 古いNetscapeスタイルの時間出力を提供する#rfc2109を追加
- HTTPステータスコードを更新
- Ruby1.8.6のサポートを解除
  - テストに通らない可能性が高いため

### 01-28
#### 1.5.1
- Rack::Lint
  - HijackWrapper#check_hijackがSPECの他の部分に準拠
- Rack::Session
  - 互換性のためAbstract::ID::SessionHashにハッシュlikeなメソッドを追加
- 各種ドキュメントの修正

### 02-07
#### 1.1.6
- Rack::Session::Cookieに対する攻撃CVE-2013-0263を修正

#### 1.2.8
- Rack::Session::Cookieに対する攻撃CVE-2013-0263を修正

#### 1.3.10
- Rack::Session::Cookieに対する攻撃CVE-2013-0263を修正

#### 1.4.5
- Rack::Session::Cookieに対する攻撃CVE-2013-0263を修正
- Rack::File のシンボリックリンクパストラバーサルCVE-2013-0262修正

#### 1.5.2
- Rack::Session::Cookieに対する攻撃CVE-2013-0263を修正
- Rack::FileのシンボリックリンクパストラバーサルCVE-2013-0262修正
- Railsの互換性を高めるためRack::Sessionに諸々のメソッドを追加
- Rack::Request
  - #trusted_proxy?が文字列全体にのみマッチするように変更
- セキュリティ上の懸念により、Rack 1.6+においてはデフォルトでJSON cookie coderを追加
- Hostヘッダが設定されていない環境におけるRack::URLMapのホストマッチングを修正
- pidfileが上書きされる可能性のあったrace conditionを修正
- 各種ドキュメントの追加

## 2014
### 01-18
#### 1.6.0
- Rack::Response
  - Helpers#unauthorized?を追加
- リクエストレベルで圧縮を制御できるよう、Rack::Deflaterがオプションのハッシュを受け付けるように変更
- Rack::Builder
  - アプリケーションのpreloadを行う#warmupを追加
- Rac::Rquest
  - HTTP_ACCEPT_LANGUAGEを抽出する#accept_languageを追加
- rackupにRackサーバーのquiet modeを追加する`--quiet`を追加
- RFC 7231へ準拠しHTTP ステータスコードをアップデート
- RFC 2616へ準拠しヘッダ名の検証を緩和
- RFC 7230へ準拠したヘッダを指定するようにSPECをアップデート
- Rack::Etagが`etags`をweakとして正しくマーク
- Rack::Request
  - #portが複数のX-HTTP-FORWORD-PROTO値をサポート
- Rack::Utils
  - リクエストごとに含むことができる最大のパーツ数を設定するための#multipart_part_limitを追加
- developmentモードにおけるデフォルトのホストをlocalhostに変更
- その他バグ修正・パフォーマンスの向上

### 05-06
#### 1.5.3
- OkJsonのサービス拒否攻撃CVE-2014-9490を修正
- 1.5系へのバックポートバグ修正

#### 1.6.1
- OkJsonのサービス拒否攻撃CVE-2014-9490を修正
- 利用可能であればRack::Runtimeにおいてはmonotonicな時間を使用するように変更
- RACK_MULTIPART_LIMITをRACK_MULTIPART_PART_LIMITに変更
  - RACK_MULTIPART_LIMITは非推奨化され、1.7.0 で削除

### 12-04
#### 2.0.0.alpha
- ファーストパーティSameSite Cookie
  - ブラウザはCSRF攻撃防止のためサードパーティリクエストからSameSite Cookieを除外する
  - Set-CookieヘッダにおけるSameSite有効化の方法を提供
    - `response.set_cookie 'foo', value: 'bar', same_site: true`または`same_site: :strict`
    - `response.set_cookie 'foo', value: 'bar', same_site: :lax`
  - Sam-site Cookiesの仕様はバージョン7に基づく
    - https://tools.ietf.org/html/draft-west-first-party-cookies-07
- ミドルウェアの追加
  - イベントベースのミドルウェアを追加するRack::Eventミドルウェア
  - レスポンスボディは気にせず、リクエスト/レスポンスのライフサイクルにおける特定のポイントでの動作のみを気にするミドルウェア
- Rack::Request
  - レスポンスが行われている権限を計算#authorityの追加
    - h2プッシュの際に使用する
- Rack::Response
  - Helpers#cache_controlおよび#cache_control=を追加
    - レスポンスオブジェクトにキャッシュコントロールヘッダを設定するために使用
  - Helpers#etagおよびetag=を追加
    - レスポンスのetag値を設定するために使用
  - Helpers#add_headerを追加
    - 複数の値を持つレスポンスヘッダに値を追加
    - Helpers モジュールを含むレスポンスライクなクラスで利用可能
- Rack::Request
  - #add_headerを追加
- Rack::Session
  - Abstract::IDが非推奨化
    - Rack::Session::Abstract::Persistedへの移行を推奨
    - Rack::Session::Abstract::Persistedはenv ハッシュではなくリクエストオブジェクトを使用
- リクエストオブジェクトにおけるENVアクセスをモジュールにpullすることを推奨
- Rack::RequestのほとんどのメソッドをRack::Request::Helperモジュールへ移動
  - リクエストオブジェクトから値を取得するためにパブリックAPIを使用するようになった
    - ユーザーはRack::Request::Helperを自分のオブジェクトに導入することができるようになり、
      (get|set|fetch|each)_header を自分の好きなように実装することができる(ex. Proxyオブジェクト)
- ファイルやディレクトリ名に`+`を含むファイルやディレクトリが正しく処理されるように変更
  - Rack::Utils.unescape_pathを使用しURIパーサーでパスをアンエスケープする
- ポスト数が多すぎるtempfileは、自動的にクローズされるように変更
- レスポンスヘッダを操作するためのメソッドを追加
  - レスポンスlikeなクラスは、次のメソッドを定義していれば
    Rack::Response::Helpersモジュールを含むことができる
    - Rack::Response#has_header?
    - Rack::Response#get_header
    - Rack::Response#set_header
    - Rack::Response#delete_header
- Rack::Util
  - .get_byte_rangesを導入
    - envハッシュに依存せずに渡されたHTTP_RANGE文字列の値をパースする
  - このメソッドに代わり.byte_ranbgesが非推奨化
- Rack::Sessionの内部実装を変更
  - セッション情報を調べるためにRack::Requestオブジェクトを使用
  - セッションオブジェクト(Cookieなど)を扱う際、リクエストオブジェクトを一回だけallocateするだけで済むようになった
- Rack::Request
  - #initialize_copyを追加
    - リクエストが複製されたときにenvも複製されるようにする
  - リクエスト固有のデータを操作するためのメソッドを追加
    - CGIパラメータとして設定されたデータや、
    ユーザが特定のリクエストに関連付けたい任意のデータが含まれる
    - Rack::Request#has_header?
    - Rack::Request#get_header
    - Rack::Request#fetch_header
    - Rack::Request#each_header
    - Rack::Request#set_header
    - Rack::Request#delete_header
- Rack::Utils
  - "delete" Cookieヘッダを構築するためのメソッドを追加
  - ハッシュをmutatingさせるような副作用に依存せずCookieヘッダを構築できるようになった
- CVE-2015-3225 deepパラメータのパースを防止

## 2016
### 05-06
#### 2.0.0.rc1
- Rack::Session
  - Abstract::IDが非推奨化
    - Rack::Session::Abstract::Persistedへの移行を推奨
