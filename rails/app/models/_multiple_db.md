# 複数DB
### レプリカの設定
```yml
production:
  primary: # writerロール
    database: <%= ENV['DATABASE_NAME'] %>
    username: root
    password: <%= ENV['ROOT_PASSWORD'] %>
    adapter: mysql2
  primary_replica: # readerロール
    database: # マスターと同じデータベース名
    username: # マスターと異なるデータベースユーザー名
    password: # マスターと異なるパスワード
    adapter:  # マスターと同じアダプタ
    replica:  true
```

#### ロールの自動切り替え

```
$ bin/rails g active_record:multi_db
```

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

- GET / HEAD以外のリクエストは、自動的にwriterロールのDBに書き込みまれる
- 書き込み後に指定の時間が経過するまではwriterロールのDBから読み出される
- GET / HEADリクエストは、直近の書き込みがなければreaderロールのDBから読み出される

## 参照
- [Active Record で複数のデータベース利用](https://railsguides.jp/active_record_multiple_databases.html)
