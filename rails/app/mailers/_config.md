# 設定
#### `config/environments/development.rb`

```ruby
Rails.application.configure do
  # 送信するメールをファイルとして保存
  config.action_mailer.delivery_method = :file
  # 保存先の指定
  config.action_mailer.file_settings = { location: Rails.root.join('log/mails') }
end
```

#### `config/environments/test.rb`

```ruby
Rails.application.configure do
  # 送信されずActionMailer::Base.deliveries配列に格納される
  config.action_mailer.delivery_method = :test
end
```

#### `config/environments/production.rb`

```ruby
Rails.application.configure do
  config.action_mailer.smtp_settings = {
    user_name: Rails.application.credentials.smtp_user_name, # Credentialsで管理する
    password: Rails.application.credentials.smtp_password,   # Credentialsで管理する
    domain: 'ドメイン名',
    address: 'smtp.sendgrid.net', # 例(Sendgridを使用する場合)
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true,
  }
end
```

## 参照
- パーフェクトRuby on Rails[増補改訂版] P235-242
