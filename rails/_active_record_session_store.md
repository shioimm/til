# Active Record Session Store
- [Active Record Session Store](https://github.com/rails/activerecord-session_store)
- セッションを (cookieではなく) DBに保存するための機構

```
# Gemfile

gem 'activerecord-session_store'
```

```
$ bundle install
$ rails generate active_record:session_migration
$ rails db:migrate # sessionsテーブルが作成される
```

```ruby
# config/initializers/session_store.rb

Rails.application.config.session_store :active_record_store, :key => '_my_app_session'
```

- 定期的にセッションを削除する
  - 環境変数`SESSION_DAYS_TRIM_THRESHOLD`日以内に更新されていないすべてのセッションを削除する

```
$ bin/rake db:sessions:trim
```
