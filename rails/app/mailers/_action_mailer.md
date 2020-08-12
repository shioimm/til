# ActionMailer
- 参照: パーフェクトRuby on Rails[増補改訂版] P235-242

## TL;DR
- Railsが標準で提供するメール送信機能

## Usage
```
$ rails g mailer Xxx(メーラー名)
```

### メーラークラス
```ruby
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
```

```ruby
# app/mailers/xxx.rb

class Xxx < ApplicationMailer
  # メーラークラスの機能
  #   paramsオブジェクトを経由して渡されたデータを取得する
  #   メーラークラスで処理した内容をインスタンス変数に代入し、viewに渡す
  #   コールバック・ヘルパーメソッドが使用できる

  def xxxx
    @name = params[:name]
    mail(to: params[:to], subject: 'xxxx')
  end

  # Xxx.with(to: 'xxxx@example.com', name: 'xxxx').xxxx.deliver_now
  # の形式で呼び出す(ActiveJobを利用してdeliver_laterも可能)
end
```

### テンプレート
```haml
= # app/views/xxx

%p= "#{@name}様"

%p ...
```

### プレビュー
```ruby
# test/mailers/previews/xxx_preview.rb
# localhost:3000/rails/mailers/xxx で確認可能

class XxxPreview < ActionMailer::Preview
  def xxx
    Xxx.with(to: 'xxxx@example.com', name: 'xxxx').xxxx
  end
end

```

### 設定
```ruby
# config/environments/development.rb

Rails.application.configure do
  # 送信するメールをファイルとして保存
  config.action_mailer.delivery_method = :file
  # 保存先の指定
  config.action_mailer.file_settings = { location: Rails.root.join('log/mails') }
end
```

```ruby
# config/environments/test.rb

Rails.application.configure do
  # 送信されずActionMailer::Base.deliveries配列に格納される
  config.action_mailer.delivery_method = :test
end
```

```ruby
# config/environments/production.rb

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
