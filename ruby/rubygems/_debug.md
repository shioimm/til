# debug.gem
- [ruby/debug](https://github.com/ruby/debug)

```
# 起動方法1 rdbgコマンドでファイルを起動
$ rdbg FILE_NAME.rb

# -Oオプションをつけるとリモートプロセスのファイルを開く
$ rdbg -O --host IP_ADDRESS --port PORT_NUMBER path/to/FILE_NAME.rb

# リモートプロセス側でrdbgをアタッチする
$ rdbg -A
```

```
# 起動方法2 ブレークポイントを仕込んでrubyコマンドでファイルを起動
$ ruby FILE_NAME.rb
```

```ruby
require 'debug'

binding.b
```

| コマンド | 意味                                                                               |
| -        | -                                                                                  |
| c        | プログラムを再開し次のブレークポイントまで進める                                   |
| n        | ステップオーバー / 次の行へ移動し、メソッド呼び出しがあれば実行して停止            |
| s        | ステップイン / 次の行へ移動し、メソッド呼び出しがあれば実行してメソッドの中に入る  |
| q        | 終了                                                                               |
| bt       | バックトレースを出力                                                               |
