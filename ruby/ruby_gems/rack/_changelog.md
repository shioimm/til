# CHANGELOG
- 引用: [CHANGELOG](https://github.com/rack/rack/blob/master/CHANGELOG.md)

## 0.1(2007-03-03)

## 0.2(2007-05-16)
- HTTP Basic認証
- Cookieセッション
- 静的ファイルハンドラ
- Rack::Request・Rack::Responseの改良
- Rack::ShowStatusを追加
  - エラーメッセージ改良のため
- Campingアダプタのバグ修正
- Railsアダプタの削除

## 0.3(2008-02-26)
- ハンドラの追加
  - LiteSpeedハンドラ
  - SCGIハンドラ
- プールセッション
- OpenID認証
- FastCGIソケットを開くための:Portと:Fileオプション
- Rack::FileのためのLast-Modifiedヘッダ
- Rack::Builder#useがブロックを使用できるように改良
- HTTPステータス201がContent-Typeとボディを含むことができるように改良
- その他バグ修正
  - 特にクッキーの扱いに関連するもの

## 0.4(2008-08-21)
- Rack::Deflaterミドルウェアの追加
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

## 0.9(2009-01-06)
- Rack::Lintの厳密化(RFCへの準拠)
- ミドルウェアの追加
  - ConditionalGetミドルウェア
  - ContentLengthミドルウェア
  - Deflaterミドルウェア
  - Headミドルウェア
  - MethodOverrideミドルウェア
- Rack::Mimeが一般的なMIMEタイプとその拡張を提供するように改良
- Mongrelヘッダをストリーム化
- ハンドラの追加
  - Thinハンドラ
- swiftiplied Mongrelを正式にサポート
- セキュアCookie
- HeaderHashが大文字小文字を区別しないように変更
- その他バグ修正、改善

## 0.9.1(2009-01-09)
- Rack::FileとRack::Directoryに対するディレクトリトラバーサルの悪用を修正

## 1.0.0(2009-04-25)
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

## 1.0.1(2009-10-18)
- `rack.version`が変更されていなかった箇所を修正
- ピュアRubyのFCGI実装をサポート
- フォーム名に"="を含む場合の修正
  - 最初に分割してからコンポーネントをエスケープしないように変更
- 名前にセミコロンを含むfilenameパラメータの取り扱いを修正
- 正規表現を解析するネストしたパラメータにアンカーを追加
  - Stack Overflowを防ぐため
- `<<`よりも互換性のあるgzip write API を使うように変更
- `$ ruby -e`でReloaderを実行しても壊れないように修正
- WEBrickの:Hostオプションをサポート
- Ruby 1.9関連の修正

## 1.1.0(2010-01-03)
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
- Utils::Multipart.build_multipart を追加
  - Utils::Multipart.parse_multipartを補完するため
- Cookieヘルパーの設定と削除をUtilsに抽出
  - Rack::Responseの外で使用できるようにするため
- Rack::Requestのparse_queryとparse_multipartを抽出します
  - サブクラスが動作を変更できるようにするため
- RewindableInputでバイナリエンコーディングを強制するように変更
- RewindableInputを使用しないハンドラのために正しいexternal_encodingを設定

## 1.1.2(2011-03-13)
- セキュリティ修正
  - Rack::Auth::Digest::MD5
    - 認証がnilを返すと空のパスワードに対して権限が付与されてしまう問題を修正

## 1.1.3(2011-12-28)
- セキュリティ修正

## 1.2.0(2010-06-13)
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

## 1.2.1(2010-06-15)
- CGIハンドラを巻き戻せるように変更
- `spec/`を`test/`にrename

## 1.2.2(2011-03-13)
- セキュリティ修正
  - Rack::Auth::Digest::MD5
    - 認証がnilを返すと空のパスワードに対して権限が付与されてしまう問題を修正

## 1.2.3(2011-05-22)
- バグ修正
- Ruby1.8.6対応

## 1.2.4(2011-09-16)
- XSS攻撃の防止
  - Ruby1.8の正規表現エンジンのバグによって有効になったもの

## 1.3.0(2011-05-22)
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

## 1.3.1(2011-07-13)
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

## 1.3.2(2011-07-16)
- Railsとrack-test、Rack::Utils#escapeが#to__sを呼び出すように修正

## 1.3.3(2011-09-16)
- バグ修正
  - Rack::ShowExceptionsのクエリパラメータが壊れていたバグ
- Rack::Request#cookiesはが壊れた入力に対して例外を投げないように変更
- XSS攻撃の防止
  - Ruby1.8の正規表現エンジンのバグによって有効になったもの
- Rack::ConditionalGetが壊れたIf-Modified-Sinceヘルパーを扱うように変更

## 1.3.4(2011-10-01)
- URIにおけるラウンドトリップ問題の修正
  - Ruby1.9.3バックポートによるセキュリティ修正
- ドキュメントの更新
- BodyProxyが無限に再帰を引き起こす可能性があった不具合を修正
- travis-ciのサポートファイルを追加

## 1.3.5(2011-10-17)
- Rack1.3.4のバックポートによる警告を修正
