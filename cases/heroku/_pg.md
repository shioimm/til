# `heroku pg`

```
# バックアップ状況の確認
$ heroku pg:backups --app アプリケーション名

# 最新のバックアップを取得
$ heroku pg:backups:capture --app アプリケーション名

# バックアップをダウンロード
$ heroku pg:backups:download バックアップ番号 --app アプリケーション名 -o /path/to/バックアップを書き込むファイル名
```

```
# 任意のアプリケーションのDBを別のアプリケーションのDBへリストア

$ heroku pg:backups:restore (heroku pg:backups public-url --app リストア元アプリケーション名) --app リストア先アプリケーション名 --confirm リストア先アプリケーション名
```
