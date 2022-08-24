# カラムの追加後、本番DBリストアを実行の上動作確認したい
- カラムを追加するマイグレーションを実行後にDBをリストアすると、DBがリストア元の状態に変更されてしまう

```
$ heroku run rails db -a <AppName>
> (パスワードを入力)
> \d <TableName> # 追加したはずのカラムが存在しないことを確認
```

- マイグレーションを強制的に再実行する必要がある

```
$ heroku run rails db:migrate:redo
```

```
$ heroku run rails db -a <AppName>
> (パスワードを入力)
> \d <TableName> # 追加したカラムが存在することを確認
```

- Restart all dynosを実行
