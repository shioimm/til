# 設定
### `Rails.application.routes.default_url_options`

```ruby
class Application < Rails::Application
  config.action_controller.default_url_options = { ... }

  # URIスキーム
  # デフォルトではリクエスト時のURIスキームを同じスキームをレスポンスを返す
  # アプリケーション内部でURIを生成する際は default_url_options: :protocol が参照される
  # config.action_controller.default_url_options = { protocol: 'https' }

  # URLにtrailing slashを付与する
  # config.action_controller.default_url_options = { trailing_slash: true }
end
```

### `config.action_dispatch.default_headers`
- デフォルトのHTTPレスポンスヘッダ

```ruby
config.action_dispatch.default_headers = {
  'X-Frame-Options'        => 'SAMEORIGIN', # 同一ドメインでのフレームを許可
  'X-XSS-Protection'       => '0',          # 問題のあるレガシーXSS監査を無効化
  'X-Content-Type-Options' => 'nosniff',    # ブラウザによるファイルのMIMEタイプ推測を停止
  'X-Download-Options'     => 'noopen',
  'X-Permitted-Cross-Domain-Policies' => 'none',
  'Referrer-Policy' => 'strict-origin-when-cross-origin'
}
```

### `config.autoload_paths`
- 自動読み込みパスにカスタムディレクトリを追加

```ruby
config.autoload_paths += [
  "#{config.root}/app/validators",
  Rails.root.join('lib'),
  "#{config.root}/app/services",
  "#{config.root}/app/models/**/*.rb"
]
```

#### `config.autoload_once_paths`
- 再読み込みせず一回だけ自動読み込みさせるクラス・モジュール

### `config.content_security_policy`
- Content Security Policy (CSP) の設定

#### `config.content_security_policy_report_only`
- コンテンツの違反のレポートのみを行う

### `config.filter_parameters`
- ログから特定のリクエストパラメータをフィルタで除外する

```ruby
config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

### `config.force_ssl`
- TLS接続を強制する (Cookieの盗聴防止)

### `config.log_level`
- 数字の小さいレベルは大きいレベルの情報を含む
  - debug: 0 - 開発者向け (クエリを含む)
  - info:  1 - システムの操作に関連する一般的な情報
  - warn:  2 - 警告
  - error  3 - プログラムでハンドリングできるエラー
  - fatal: 4 - プログラムでハンドリングできないエラー

### `config.public_file_server.enabled`
- `/public`以下から静的ファイルを配信するかしないか
  - Produnction:
    - 静的ファイルをnginx / Apacheで配信する場合は`false`
    - Herokuでホストしている場合はtrue(静的ファイルの配信機能がないため・別途CDNが不可欠)
  - Produnction以外: `true`
