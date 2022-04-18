# ロールバック

```
# リリース番号を確認する
$ heroku releases --app <App Name>

# リリース情報の詳細を確認する
$ heroku releases:info --app <App Name> <Release ID>

# ロールバックを実行する
$ heroku rollback --app <App Name> <Release ID>
```

- デプロイに失敗しているとロールバックできない
  - デプロイに失敗している変更をrevertする場合は、revert用のPRをmergeした上でデプロイし直す

## 参照
- [Releases](https://devcenter.heroku.com/articles/releases)
