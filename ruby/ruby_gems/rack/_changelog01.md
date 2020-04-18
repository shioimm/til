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
- ハンドラの追加
  - LiteSpeedハンドラ
  - SCGIハンドラ
- プールセッション
- OpenID認証
- :Portと:Fileオプション
  - FastCGIソケットを開くため
- Last-Modifiedヘッダ
  - Rack::Fileのため
- Rack::Builder#useがブロックを使用できるように変更
- HTTPステータス201がContent-Typeとボディを含むことができるように変更
- その他バグ修正
  - 特にクッキーの扱いに関連するもの

### 08-21
#### 0.4
- ミドルウェアの追加
  - Rack::Deflaterミドルウェア
- OpenID認証のためにruby-openid2を必須化
- Memcacheセッション
- 明示的なEventedMongrelハンドラ
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
- Rack::Lintの厳密化
  - RFCへ準拠
- ミドルウェアの追加
  - ConditionalGetミドルウェア
  - ContentLengthミドルウェア
  - Deflaterミドルウェア
  - Headミドルウェア
  - MethodOverrideミドルウェア
- Rack::Mimeが一般的なMIMEタイプとその拡張を提供するように変更
- Mongrelヘッダをストリーム化
- ハンドラの追加
  - Thinハンドラ
- swiftiplied Mongrelを正式にサポート
- セキュアCookie
- HeaderHashが大文字小文字を区別しないように変更
- その他バグ修正、改善

### 01-09
#### 0.9.1
- Rack::FileとRack::Directoryに対するディレクトリトラバーサルの悪用を修正

### 04-25
#### 1.0.0
- SPEC change
  - Rack::VERSION[1,0]
  - ヘッダの値を文字列に指定
  - Content-Lengthが欠落している場合、チャンク化された転送エンコーディングが使用されるようにする
  - `rack.input`は巻き戻し可能、かつバッファへの読み込みをサポートするようにする
  - `rack.session`が指定されるようにする
  - ボディに対して追加で#to_pathが呼べるように変更
    - ファイル名を指定すること
    - 単一の文字列からなる配列を使用すること
- ミドルウェアの追加
  - Rack::Lockミドルウェア
  - Rack::ContentTypeミドルウェア
- Rack::Reloaderの書き換え
- Rack::Auth::OpenIDのメジャーアップデート
- Rack::Responseで入れ子になったパラメータの解析をサポート
- Rack::Responseでリダイレクトをサポート
- Rack::ResponseでCookieのHttpOnlyをサポート
- Rakefileの書き換え
- その他バグ修正、改善

### 10-18
#### 1.0.1
- `rack.version`が変更されていなかった箇所を修正
- ピュアRubyによるFCGI実装をサポート
- フォーム名に"="を含む場合の修正
  - 最初に分割してからコンポーネントをエスケープしないように変更
- 名前にセミコロンを含むfilenameパラメータの取り扱いを修正
- 正規表現を解析するネストしたパラメータにアンカーを追加
  - Stack Overflowを防ぐため
- `<<`よりも互換性のあるgzip write API を使うように変更
- `$ ruby -e`でReloaderを実行しても壊れないように修正
- WEBrickの:Hostオプションをサポート
- Ruby 1.9関連の修正

## 2010
### 01-03
#### 1.1.0
- Auth::OpenIDをrack-contribに移動
- SPEC change
  - 必要な型のサブクラスを許可するためにLintを緩和
  - `rack.input`がバイナリモードに変更
- SPEC define
  - `rack.logger`の仕様を定義
- ファイルサーバがX-Cascadeヘッダをサポート
- ミドルウェアの導入
  - Configミドルウェア
  - ETagミドルウェア
  - Runtimeミドルウェア
  - Sendfileミドルウェア
- ミドルウェアの追加
  - NullLoggerミドルウェア
- ロガーの追加
- `.ogv`と`.manifest`にMIMEタイプを追加
- PATH_INFOのスラッシュを絞らないように変更
- Content-Typeを使用してPOSTパラメータをパースするように変更
- Rack::Utils::HTTP_STATUS_CODESハッシュのupdate
- ステータスコード検索ユーティリティの追加
- レスポンスメッセージ構築時、ステータスコードに対して#to_iを呼び出すように変更
- Rack::Request#user_agentを追加
- Rack::Request#hostで転送されたホストを把握できるように変更
- HTTP_HOSTとSERVER_NAMEの両方が欠落している場合、Request#hostに対して空の文字列を返すように変更
- MockRequestがハッシュパラメータを受け付けることを許可するように変更
- HeaderHashの最適化
- rackupをRack::Serverにリファクタリング
- Utils.build_nested_queryを追加
  - Utils.parse_nested_queryを補完するため
- Utils::Multipart.build_multipartを追加
  - Utils::Multipart.parse_multipartを補完するため
- Cookieヘルパーの設定と削除をUtilsに抽出
  - Rack::Responseの外で使用できるようにするため
- Rack::Requestのparse_queryとparse_multipartを抽出します
  - サブクラスが動作を変更できるようにするため
- RewindableInputでバイナリエンコーディングを強制するように変更
- RewindableInputを使用しないハンドラのために正しいexternal_encodingを設定

### 06-13
#### 1.2.0
- Campingアダプタを削除
  - Camping 2.0はrackをそのままサポート
- 引用符で囲まれた値の解析を削除
- メソッドの追加
  - Request.trace?
  - Request.options?
- .webmと.htcのmime-typeを追加
- HTTP_X_FORWARDED_FORを修正
- その他multipartの修正
- テストをbaconに変更

### 06-15
#### 1.2.1
- CGIハンドラを巻き戻せるように変更
- `spec/`を`test/`にrename

## 2011
### 03-13
#### 1.1.2
- セキュリティ対応
  - Rack::Auth::Digest::MD5
    - 認証がnilを返すと空のパスワードに対して権限が付与されてしまう問題を修正

#### 1.2.2
- セキュリティ対応
  - Rack::Auth::Digest::MD5
    - 認証がnilを返すと空のパスワードに対して権限が付与されてしまう問題を修正

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
- `..`を持つファイルを許可し、`..`のパスコンポーネントを許可しない
- rackupがコマンドラインでハンドラ固有のオプションを受け付けるように変更
- Request#paramはPOSTをGETにマージしないように変更(同じものを返す)
- エスケープにURI.encode_www_form_component・コアメソッドを使用するように変更
- 設定ファイルで複数行のコメントを許可
- クエリパラメータのエスケープを解除
- Rack::Responseは適切な場合にContent-Lengthを削除するように変更
- Rack::Deflaterがストリーミングをサポート
- Rack::Handler の読み込みと検索を改善
- PATCHメソッドのサポート
- `env['rack.session.options']`にセッションオプションが含まれるように変更
- Cookieの互換性を保って更新
- セッションミドルウェアでSecureRandom.hexを使用するように変更

### 07-13
#### 1.3.1
- Ruby1.9.1をサポート
- JRubyをサポート
- Rack::Utils.escapeで$KCODEを適切に処理するように変更
- method_missing/respond_toの動作を統一
  - Rack::Lock
  - Rack::Auth::Digest::Request
  - Rack::Multipart::UploadedFile
- セッションミドルウェアへの rack.session の受け渡しを有効化
- Rack::CommonLoggerがストリーミング応答を正しく処理するように変更
- Rack::MockResponseがbodyオブジェクトのcloseを呼び出すように変更
- DOS vectorの修正(MRI stdlib backportから)

### 07-16
#### 1.3.2
- Railsとrack-test、Rack::Utils#escapeが#to__sを呼び出すように修正

### 09-16
#### 1.2.4
- XSS攻撃の防止
  - Ruby1.8の正規表現エンジンのバグによって有効になったもの

#### 1.3.3
- バグ修正
  - Rack::ShowExceptionsのクエリパラメータが壊れていたバグ
- Rack::Request#cookiesはが壊れた入力に対して例外を投げないように変更
- XSS攻撃の防止
  - Ruby1.8の正規表現エンジンのバグによって有効になったもの
- Rack::ConditionalGetが壊れたIf-Modified-Sinceヘルパーを扱うように変更

### 10-01
#### 1.3.4
- URIにおけるラウンドトリップ問題の修正
  - Ruby1.9.3バックポートによるセキュリティ修正
- ドキュメントの更新
- BodyProxyが無限に再帰を引き起こす可能性があった不具合を修正
- travis-ciのサポートファイルを追加

### 10-17
#### 1.3.5
- Rack1.3.4のバックポートによる警告を修正

### 12-28
#### 1.1.3
- セキュリティ対応

#### 1.4.0
- Ruby1.8.6のサポートを正式に終了
- config.ruに対する修正
  - 壊れたconfig.ruに対するエラーメッセージを修正
  - config.ruで`run`と`map`を組み合わせることができるように修正
- Rack::ContentTypeがボディのないレスポンスにContent-Typeを設定しないように変更
- ステータスコード205はレスポンスボディを送信しないように変更
- Rack::Response::Helperがインスタンス変数に依存しないように変更
- Rack::Utils.build_queryがnilのクエリ値に対して'='を出力しないように変更
- MIMEタイプの追加
- Rack::MockRequestがHEADをサポート
- Rack::DirectoryがRFC3986予約文字を含むファイルをサポート
- Rack::FileがGETとHEADリクエストのみをサポート
- Rack::Server#startはRack::Handler::#runにブロックを渡すように変更
- Rack::Staticがインデックスオプションをサポート
- Teapotのステータスコードを追加
- rackupはデフォルトでMongrelの代わりにThinを使用するように変更
  - インストールされている場合
- HTTP_X_FORWARDED_SCHEMEのサポートを追加
- その他バグ修正

## 2012
### 01-22
#### 1.4.1
- キースペース制限の計算を変更し、ネストされたパラメータの問題を軽減。
- ファイルにエスケープされていない`%`が含まれている場合のmultipart解析について回避策を追加
- Rack::Response::Helperers#method_not_allowed?を追加(ステータスコード405)
- Rack::Fileが不正なディレクトリトラバースに対して404を返すように修正
- Rack::Fileが不正なメソッド(HEAD/GET以外)に対して405を返すように修正
- Rack::Cascadeがデフォルトで405を捕捉するように変更
- Cookieが`--`を含まない場合に例外を発生しないように変更
- ドキュメントの修正
- Rack::BodyProxyが常にブロックを実行することを担保
- Cookieとsecretに関するテストの追加
- Rack::Session::Cookieをsecretまたはold_secret のいずれかで提供できるように変更
- テストの修正
- Rack::Staticがデフォルトでインデックスファイルの提供を行わないように変更
- Rack.releaseを修正

## 2013
### 01-06
#### 1.1.4
- ユーザーがsession secretを提供しなかった場合の警告を追加

#### 1.2.6
- ユーザーがsession secretを提供しなかった場合の警告を追加
- 引用符で囲まれていないファイル名の解析パフォーマンスを修正

#### 1.3.7
- ユーザーがsession secretを提供しなかった場合の警告を追加
- 引用符で囲まれていないファイル名の解析パフォーマンスを修正
- URIのバックポートを更新
- URIのバックポートのバージョンマッチングを修正し、一定の警告を表示しないように変更
- 空の値で正しいパラメータ解析を行うように変更
- rackupの修正・変更
  - 複数使用を可能にする`-I` フラグ
  - pidfileの取り扱い
  - ライン番号を正しくレポート
- 時間制限のあるnon-stale noncesによって引き起こされるリクエストループを修正
- Windowsでのリローダーの修正
- Response#to_aryからの再帰ループを防ぐ
- ボディクローズ仕様に準拠した各種ミドルウェアの推奨
- ボディクローズ仕様の言語を更新
- ECMAエスケープの互換性問題に関する注意事項を追加
- Rangeヘッダにおける複数範囲のパースを修正

#### 1.4.2
- ユーザーがsession secretを提供しなかった場合の警告を追加
- 引用符で囲まれていないファイル名の解析パフォーマンスを修正
- URIのバックポートを更新
- URIのバックポートのバージョンマッチングを修正し、一定の警告を表示しないように変更
- 空の値で正しいパラメータ解析を行うように変更
- rackupの修正・変更
  - 複数使用を可能にする`-I` フラグ
  - pidfileの取り扱い
  - ライン番号を正しくレポート
- 時間制限のあるnon-stale noncesによって引き起こされるリクエストループを修正
- Windowsでのリローダーの修正
- Response#to_aryからの再帰ループを防ぐ
- ボディクローズ仕様に準拠した各種ミドルウェアの推奨
- ボディクローズ仕様の言語を更新
- ECMAエスケープの互換性問題に関する注意事項を追加
- Rangeヘッダにおける複数範囲のパースを修正
- 空のパラメータキーからのエラーを防止
- Rack::RequestにPATCHメソッドを追加
- 各種ドキュメントの更新
- セッションマージのセマンティクスを修正
  - rack-testの修正
- Rack::Static :indexが複数のディレクトリを扱えるように変更
- すべてのテストがRack::Lintを利用するように変更
- Rack::Fileにおけるcache_controlパラメータが非推奨化
  - Rack 1.5.0で削除
- Rack::Directoryスクリプト名のエスケープを修正
- Rack::Staticがsophisticatedな設定のためのヘッダルールをサポート
- multipart解析がContent-Lengthヘッダなしでの動作を保証
- ロゴマークの刷新
- Rack::BodyProxyが#eachを明示的に定義
- URIがエスケープされていないCookieが例外を送出しないように変更

### 01-07
#### 1.3.8
- セキュリティ対応
  - Content-Typeヘッダにおける大規模なmultipart boundaryでのバインドされていない読み取りの防止

#### 1.4.3
- セキュリティ対応
  - Content-Typeヘッダにおける大規模なmultipart boundaryでのバインドされていない読み取りの防止

### 01-13
#### 1.1.5
- セキュリティ対応
  - Rack::Auth::AbstractRequestが任意の文字列をシンボル化しないように変更
- 1.3.x系のテストケースの誤りを修正

#### 1.2.7
- セキュリティ対応
  - Rack::Auth::AbstractRequestが任意の文字列をシンボル化しないように変更
- 1.3.x系のテストケースの誤りを修正

#### 1.3.9
- セキュリティ対応
  - Rack::Auth::AbstractRequestが任意の文字列をシンボル化しないように変更
- 1.3.x系のテストケースの誤りを修正

#### 1.4.4
- セキュリティ対応
  - Rack::Auth::AbstractRequestが任意の文字列をシンボル化しないように変更
- 1.3.x系のテストケースの誤りを修正

### 01-21
#### 1.5.0
- ハイジャックSPECの導入
  - レスポンス前後のハイジャックを実現するため
- SessionHashをHashのサブクラスから解除
- ヘッダオプションの代わりに使用されていたRack::File cache_controlパラメータの削除
- Rack::Auth::AbstractRequest#schemeが文字列を返すように変更
  - 元々シンボルを返していた
- Rack::UtilsのCookie機能のフォーマットがRFC 2822 フォーマットにより期限切れ
- Rack::FileにデフォルトのMIMEタイプを追加
- rackup -b 'run Rack::Files.new(".")' オプションによりコマンドライン設定を提供
- Rack::Deflaterがレスポンスボディをダブルエンコードしな異様に変更
- Rack::Mime#match?の追加
  - Acceptヘッダのマッチングに便利
- Rack::Utils#q_valuesがAcceptヘッダの分割を提供
- Rack::Utils#best_q_matchがAcceptヘッダのヘルパーを提供
- Rack::Handler.pickの追加
  - 利用可能なサーバーを見つけるための便利な機能を提供
- デフォルトサーバーのリストにPumaを追加
  - Webrickより優先される
- 各種ミドルウェアの置き換え時にbodyを正しく閉じるように変更
- GETパラメータのみの場合Rack::Request#paramsが永続化しないように変更
- Rack::Request#update_param / #delete_paramが永続的な操作を提供
- Rack::Request#trusted_proxy?の追加
- Rack::ResponseがContent-Type を強制しないように変更
- Rack::Sendfileがローカルマッピングの設定オプションを提供
- Rack::Utils#rfc2109は古いNetscapeスタイルの時間出力を提供
- HTTPステータスコードを更新
- Ruby1.8.6のサポートを解除
  - テストに通らない可能性が高いため

### 01-28
#### 1.5.1
- Rack::Lint check_hijackがSPECの他の部分に準拠
- Abstract::ID::SessionHashにハッシュlikeなメソッドを追加
  - 互換性のため
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
- Rack::File のシンボリックリンクパストラバーサルCVE-2013-0262修正
- Sessionに諸々のメソッドを追加
  - Railsの互換性を高めるため
- Request#trusted_proxy?が文字列全体にのみマッチするように変更
- Rack 1.6+ではデフォルトのJSON cookie coderを追加
  - セキュリティ上の懸念により
- ホストヘッダを設定していない環境でのURLMapホストマッチングを修正
- pidfileが上書きされる可能性のあった競合状態を修正
- 各種ドキュメントの追加

## 2014
### 01-18
#### 1.6.0
- Response#unauthorized?ヘルパーの追加
- Deflaterがオプションのハッシュを受け付けるように変更
  - リクエストレベルで圧縮を制御できるようになった
- Builder#warmupの追加
  - アプリケーションのpreloadを行う
- Request#accept_languageの追加
  - HTTP_ACCEPT_LANGUAGEを抽出する
- Rackサーバーにquiet modeを追加
  - `rackup --quiet`
- RFC 7231への準拠 -> HTTP ステータスコード
- RFC 2616への準拠 -> ヘッダ名の検証の緩和
- RFC 7230への準拠 -> RFC 7230に準拠したヘッダを指定するようにSPECを更新
- Etagが`etags`をweakとして正しくマーク
- Request#portが複数のX-HTTP-FORWORD-PROTO値をサポート
- Utils#multipart_part_limitにリクエストが含むことができる最大のパーツ数を設定できるように変更
- developmentモードでのデフォルトのホストをlocalhostに変更
- その他バグ修正・パフォーマンスの向上

### 05-06
#### 1.5.3
- OkJsonのサービス拒否攻撃CVE-2014-9490を修正
- 1.5系へのバックポートバグ修正

#### 1.6.1
- OkJsonのサービス拒否攻撃CVE-2014-9490を修正
- Rack::Runtimeがmonotonicな時間を使用するように変更
  - 利用可能時
- RACK_MULTIPART_LIMITをRACK_MULTIPART_PART_LIMITに変更
  - (RACK_MULTIPART_LIMITは非推奨化し、1.7.0 で削除

### 12-04
#### 2.0.0.alpha
- ファーストパーティのSameSite Cookie
  - ブラウザはサードパーティのリクエストからSameSite Cookieを除外する
    - CSRF攻撃防止のため
  - Set-CookieヘッダのSameSite有効化の方法を提供
    - `response.set_cookie 'foo', value: 'bar', same_site: true`または`same_site: :strict`
    - `response.set_cookie 'foo', value: 'bar', same_site: :lax`
  - Sam-site Cookiesの仕様はバージョン7に基づく
    - https://tools.ietf.org/html/draft-west-first-party-cookies-07
- ミドルウェアの追加
  - Rack::Eventミドルウェア
    - イベントベースのミドルウェアを追加する
- Rack::Request#authorityの追加
  - レスポンスが行われている権限を計算
    - h2プッシュの際に便利
- Rack::Response::Helpers#cache_controlおよびcache_control=の追加
  - Responseオブジェクトにキャッシュコントロールヘッダを設定するために使用
- Rack::Response::Helpers#etagおよびetag=を追加
  - レスポンスのetag値を設定するために使用
- Rack::Response::Helpers#add_headerを導入
  - 複数の値を持つレスポンスヘッダに値を追加
  - 他のResponse#xxx_headerメソッドの観点から実装されている
  - Helpers モジュールを含むレスポンスライクなクラスであればどのようなものでも利用可能
- Rack::Request#add_headerを追加
- Rack::Session::Abstract::IDが非推奨化
  - Rack::Session::Abstract::Persistedへの移行が必要
  - Rack::Session::Abstract::Persistedはenv ハッシュではなくRequestオブジェクトを使用
- Requestオブジェクト内のENVアクセスをモジュールにpullすることを推奨
  - ENVベースかつRack::Requestを継承したくないレガシーなRequestオブジェクトのため
- Rack::RequestのほとんどのメソッドをRack::Request::Helperモジュールへ移動
  - Requestオブジェクトから値を取得するためにパブリックAPIを使用できるようになった
    - ユーザーはRack::Request::Helperを自分のオブジェクトに導入することができるようになり、
      (get|set|fetch|each)_header を自分の好きなように実装することができる(ex. Proxyオブジェクト)
- ファイルやディレクトリ名に`+`を含むファイルやディレクトリが正しく処理されるように修正
  - フォームのようにパスをアンエスケープするのではなく、
    Rack::Utils.unescape_pathを使用しURIパーサーでアンエスケープを行う
- tempfileはポスト数が多すぎる場合、自動的にクローズされるように変更
- レスポンスヘッダを操作するためのメソッドを追加
  - レスポンスlikeなクラスは、次のメソッドを定義していれば
    Rack::Response::Helpersモジュールを含むことができる
    - Rack::Response#has_header?
    - Rack::Response#get_header
    - Rack::Response#set_header
    - Rack::Response#delete_header
- Util.get_byte_rangesを導入
  - envハッシュに依存せずに渡されたHTTP_RANGE文字列の値を解析する
- セッションの内部を変更し、セッション情報を調べるためにRequest オブジェクトを使用するように変更
  - Sessionオブジェクトを扱う際に1 つのRequestオブジェクトを割り当てるだけで済むようになった
    - Cookieなどを操作する場合、一度の割り当てで済む
- Rack::Request#initialize_copyを追加
  - リクエストが複製されたときにenvが複製されるようにする
- リクエスト固有のデータを操作するためのメソッドを追加
  - CGIパラメータとして設定されたデータや、
    ユーザが特定のリクエストに関連付けたい任意のデータが含まれる
    - Rack::Request#has_header?
    - Rack::Request#get_header
    - Rack::Request#fetch_header
    - Rack::Request#each_header
    - Rack::Request#set_header
    - Rack::Request#delete_header
- "delete" Cookieヘッダを構築するメソッドを追加
  - lib/rack/utils.rb
  - ハッシュを変異させる副作用に依存せずにCookieヘッダを構築できるようになった
- deepパラメータのパースを防止
  - CVE-2015-3225

## 2016
### 05-06
#### 2.0.0.rc1
- Rack::Session::Abstract::IDが非推奨化
  - Rack::Session::Abstract::Persistedへの移行が必要
