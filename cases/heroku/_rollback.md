# デプロイ後にロールバックしたい

```
# リリース番号を確認する
$ heroku releases --app アプリケーション名

# リリース情報の詳細を確認する
$ heroku releases:info --app アプリケーション名 リリース番号

# ロールバックを実行する
$ heroku rollback --app アプリケーション名 リリース番号
```

## 参照
- [Releases](https://devcenter.heroku.com/articles/releases)
