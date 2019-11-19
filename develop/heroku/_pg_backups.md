## DBバックアップ
- 参照: [Heroku PGBackups](https://devcenter.heroku.com/articles/heroku-postgres-backups)

### バックアップの作成
- 参照: [Creating a backup](https://devcenter.heroku.com/articles/heroku-postgres-backups#creating-a-backup)

```
heroku pg:backups:capture --app sushi
```

#### バックアップのスケジュール実行
- 参照: [Scheduling backups](https://devcenter.heroku.com/articles/heroku-postgres-backups#scheduling-backups)

### バックアップ状況の確認
- 参照: [Checking backup status](https://devcenter.heroku.com/articles/heroku-postgres-backups#checking-backup-status)

```
# バックアップ一覧

heroku pg:backups --app sushi
```

```
# バックアップ詳細
# bXXXは一覧で表示されるバックアップID

heroku pg:backups:info b017 --app sushi
```

### ダウンロード
- 参照: [Downloading your backups](https://devcenter.heroku.com/articles/heroku-postgres-backups#downloading-your-backups)

```
# バックアップURLを作成する場合(60分間有効)
# バックアップIDを指定しない場合は最新のバックアップが対象になる

heroku pg:backups:url b001 --app sushi
```

```
# コマンドラインからダウンロードする場合

heroku pg:backups:download
```

### リストア
- 参照: [Restoring backups](https://devcenter.heroku.com/articles/heroku-postgres-backups#restoring-backups)

```
heroku pg:backups:restore b101 DATABASE_URL --app sushi
```
