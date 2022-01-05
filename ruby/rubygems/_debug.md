# debug.gem
- [ruby/debug](https://github.com/ruby/debug)

```
$ gem i debug
$ rdbg -v
```

```ruby
require 'debug'

binding.break
```

| コマンド | 意味                                                                               |
| -        | -                                                                                  |
| c        | プログラムを再開し次のブレークポイントまで進める                                   |
| n        | ステップオーバー / 次の行へ移動し、メソッド呼び出しがあれば実行して停止            |
| s        | ステップイン / 次の行へ移動し、メソッド呼び出しがあれば実行してメソッドの中に入る  |
| q        | 終了                                                                               |
