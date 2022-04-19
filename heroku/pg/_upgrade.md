# DBプランアップグレード (`pg:copy`)

```
# 新しいDBのプロビジョニング
$ heroku addons:create heroku-postgresql:standard-0 --app <App Name>
$ heroku pg:wait -a <App Name>

# メンテナンスモード開始
$ heroku maintenance:on --app <App Name>

# 新しいDBのURLを確認
$ heroku pg:info --app <App Name>

# 古いDBから新しいDBへデータをコピー
$ heroku pg:copy DATABASE_URL HEROKU_POSTGRESQL_???? --app <App Name>

# 新しいDBをプロモート
# フォロワーDBがある場合はプロモート後にフォロワー用のDBを作成する必要がある
$ heroku pg:promote HEROKU_POSTGRESQL_???? --app <App Name>

# メンテナンスモード終了
$ heroku maintenance:off --app <App Name>

# 古いDBの削除
$ heroku addons:destroy HEROKU_POSTGRESQL_???? --app <App Name>
```

## 参照
- [Upgrading the Version of a Heroku Postgres Database](https://devcenter.heroku.com/articles/upgrading-heroku-postgres-databases)
