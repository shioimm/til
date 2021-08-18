# デプロイ後にロールバックしたい

```
# リリース番号を確認する
$ heroku releases --app アプリケーション名

# リリース情報の詳細を確認する
$ heroku releases:info --app アプリケーション名 リリース番号

# ロールバックを実行する
$ heroku rollback --app アプリケーション名 リリース番号
```

- デプロイに失敗しているとロールバックできない
  - デプロイに失敗している変更をrevertする場合は、revert用のPRをmergeした上でデプロイし直す

## 参照
- [Releases](https://devcenter.heroku.com/articles/releases)
