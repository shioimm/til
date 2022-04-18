# バックアップ / リストア
```
# バックアップ一覧
$ heroku pg:backups -a <Produnction App Name>

# バックアップ詳細
$ heroku pg:backups:info b*** --app <Produnction App Name>

# 最新のバックアップを作成
$ heroku pg:backups:capture -a <Produnction App Name>
```

#### Review Appsにリストア
```
$ heroku pg:backups:restore `heroku pg:backups public-url -a <Produnction App Name>` -a <Review App Name> --confirm <Review App Name>
```

#### 開発環境にリストア
```
# ダウンロード
$ heroku pg:backups:download <Backup ID> -a <Produnction App Name> -o /path/to/<Dumpfile Name>.dump

# リセット
$ bin/rails db:migrate:reset RAILS_ENV=development

# リストア
$ pg_restore --verbose --data-only --no-owner --no-acl --disable-triggers -h localhost -d <App Name>_development -U username -p 5432 ../<Dumpfile Name>>.dump
```

## 参照
- [Heroku PGBackups](https://devcenter.heroku.com/articles/heroku-postgres-backups)
- [Creating a backup](https://devcenter.heroku.com/articles/heroku-postgres-backups#creating-a-backup)
- [Scheduling backups](https://devcenter.heroku.com/articles/heroku-postgres-backups#scheduling-backups)
- [Checking backup status](https://devcenter.heroku.com/articles/heroku-postgres-backups#checking-backup-status)
- [Downloading your backups](https://devcenter.heroku.com/articles/heroku-postgres-backups#downloading-your-backups)
- [Restoring backups](https://devcenter.heroku.com/articles/heroku-postgres-backups#restoring-backups)
