# Yarnの依存関係がインストールされていない状況で`bin/setup`を実行すると`rails db:prepare`で落ちる

```ruby
# Install JavaScript dependencies
  system('bin/yarn') # コメントアウトを外す
```
