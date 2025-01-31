# テスト
#### コンパイルしたRubyを使って別のリポジトリのテストを実行したい

```
# $ pwd
# .../path/to/drb

$ RUBYLIB=~/src/ruby/tool/lib RUBY=~/src/install/bin/ruby rake test
$ RUBYLIB=~/src/ruby/gem/lib RUBY=~/src/install/bin/ruby rake test
```
