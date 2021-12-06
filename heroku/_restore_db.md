# 本番DBをリストアする
```
$ heroku pg:backups -a PRODUCTION_APP_NAME

# 最新のバックアップを取得
$ heroku pg:backups:capture -a PRODUCTION_APP_NAME
```

#### Review Appsにリストア
```
$ heroku pg:backups:restore `heroku pg:backups public-url -a PRODUCTION_APP_NAME` -a REVIEW_APP_NAME --confirm REVIEW_APP_NAME
```

#### 開発環境にリストア
```
$ heroku pg:backups:download BACKUP_ID -a PRODUCTION_APP_NAME -o /path/to/DUMPFILE_NAME.dump
$ bin/rails db:migrate:reset RAILS_ENV=development
$ pg_restore --verbose --data-only --no-owner --no-acl --disable-triggers -h localhost -d APP_NAME_development -U username -p 5432 ../DUMPFILE_NAME.dump
```
