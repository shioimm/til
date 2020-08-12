# ActionMailbox
- 参照: パーフェクトRuby on Rails[増補改訂版] P243-254

## TL;DR
- Railsが標準で提供するメール受信機能

### 処理の流れ
1. メールサーバーにメールが届く
2. メールサーバーがメールデータを添えてRailsアプリケーションの特定のURLヘリクエストを投げる
3. ActionMailboxがメールデータを保存したり、メールに応じて非同期処理を行う

#### リクエスト受信後の処理の流れ
1. リクエストの認証を行い、パスワードを検証
2. InboundEmailモデルのレコードを作成
   InboundEmail - メールの処理状態を管理するモデル
3. メールデータをActiveStorage経由で保存
4. ActiveJobを使用して受信メールに対する処理を非同期処理バックエンドのキューに追加
   メールの内容に応じてキューごとに振り分けを行う(`routing { 条件 => :振り分け先 }`)
5. メールサーバーにレスポンスを返す

### 対応するメールサーバー
- Mailgun
- Mandrill
- Postmark
- Sendgrid
- Exim
- Postfix
- Qmail

### 関連する機能
- ActiveStorage - 受信メールの保存
- ActiveJob - メールに応じた非同期処理・メールデータの一定期間後削除

## Usage
```
# ActionMailboxのマイグレーションファイルを生成
# ActiveStorage::Blob/ActiveStorage::Attachmentがない場合はそのマイグレーションファイルも生成
$ rails action_mailbox:install

$ rails db:migrate
```
```ruby
# 処理の振り分け先Mailboxクラスを生成

$ rails g mailbox xxx
```

```ruby
# config/environments/production.rb

Rails.application.configure do
  config.action_mailbox.ingress = :sendgrid # 使用するメールサーバーを指定
end
```

```ruby
# ActionMailboxはCredentialから自動でingress_passwordを読み取る

action_mailbox:
  ingress_password: XXXX
```

- SendgridでParse Webhookを設定する
  - Parse Webhook - メール受信時にメール内容を添えて指定されたURLへPOSTする機能
  - ドメインのDNS設定でMXレコードを設定
  - Domain Authenticationを設定
  - Inbound Parseにリクエスト先URLを指定
    - `https:action_mailbox:XXXX(パスワード)@ドメイン名/rails/action_mailbox/sendgrid/inbound_emails`
  - Post the raw, full MIME messageをチェック

```ruby
# app/mailboxes/application_mailbox.rb

class ApplicationMailbox < ActionMailbox::Base
  # 最初にマッチした条件によって:xxxのMailboxクラスへ処理が進む

  routing /something/i => :xxx
end
```

```ruby
# xxxのMailboxクラス
# app/mailboxes/xxx_mailbox.rb

class XxxMailbox < ApplicationMailbox
  before_processing :validate_request

  def process
    # 非同期処理の実装
  end

  private

    def validate_request
      # バリデーションメソッド
    end
end
```

### 開発用UI
- `http://localhost:3000/rails/conductor/action_mailbox/inbound_emails`
