# database.yml
- 参照: [ActiveRecord による Ruby での並列性とデータベース接続](https://devcenter.heroku.com/ja/articles/concurrency-and-database-connections)

```yml
default: &default
  pool: 5       # DBへの同時接続可能数 上限を越えると接続はブロックされる
  timeout: 5000 # 接続を取得できない場合のタイムアウト時間
```

- DB自体の接続可能数を超えないようにする
  - Herokuの場合`dyno数 * アプリケーションサーバーのスレッド数 <= DBの接続可能数`になるようにする

### 接続プールのサイズ変更
- マルチスレッドサーバーの場合、直接`database.yml`内に設定する(Rails 4.1~)
  - pumaを使用している場合はpool値をpumaのスレッド数`ENV['RAILS_MAX_THREADS']`に指定する
    - refs: config/puma.rb
```
production:
  url:  <%= ENV["DATABASE_URL"] %>
  pool: <%= ENV["DB_POOL"] || ENV['RAILS_MAX_THREADS'] || 5 %>
```

#### アクティブな接続の数
```
$ bundle exec rails dbconsole

# select count(*) from pg_stat_activity where pid <> pg_backend_pid() and usename = current_user;
```
