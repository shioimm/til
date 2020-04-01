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

## 1.0(2009-04-25)
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
