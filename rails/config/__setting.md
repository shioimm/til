# 設定
### `Rails.application.config.autoload_paths`
- 自動読み込みパスにカスタムディレクトリを追加

```ruby
Rails.application.config.autoload_paths += [
  "#{config.root}/app/validators",
  Rails.root.join('lib'),
  "#{config.root}/app/services",
  "#{config.root}/app/models/**/*.rb"
]
```

#### `Rails.application.config.autoload_once_paths`
- 再読み込みせず一回だけ自動読み込みさせるクラス・モジュール

### `Rails.application.config.filter_parameters`
- ログから特定のリクエストパラメータをフィルタで除外する

```ruby
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
]
```

### `Rails.application.config.log_level`
- 数字の小さいレベルは大きいレベルの情報を含む
  - debug: 0 - 開発者向け (クエリを含む)
  - info:  1 - システムの操作に関連する一般的な情報
  - warn:  2 - 警告
  - error  3 - プログラムでハンドリングできるエラー
  - fatal: 4 - プログラムでハンドリングできないエラー

### `Rails.application.config.public_file_server.enabled`
- `/public`以下から静的ファイルを配信するかしないか
  - Produnction:
    - 静的ファイルをnginx / Apacheで配信する場合は`false`
    - Herokuでホストしている場合はtrue(静的ファイルの配信機能がないため・別途CDNが不可欠)
  - Produnction以外: `true`
