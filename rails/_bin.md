## `bin/setup`
- 新しいリポジトリの開発に参加する際にセットアップを行う

### トラブルシューティング
- Yarnの依存関係がインストールされていない状況で`bin/setup`を実行すると
`rails db:prepare`のタイミングで落ちる
```ruby
# Install JavaScript dependencies
  system('bin/yarn') # コメントアウトを外す
```
