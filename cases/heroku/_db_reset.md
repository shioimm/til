# DBをリセットする
- `rails`コマンドからはリセットできない

```
$ heroku run rails db:reset --app アプリケーション名

ActiveRecord::ProtectedEnvironmentError: You are attempting to run a destructive action against your 'production' database.
If you are sure you want to continue, run the same command with the environment variable:
```

- `pg`コマンドでリセットする
```
$ heroku pg:reset --app アプリケーション名 --confirm アプリケーション名
```
