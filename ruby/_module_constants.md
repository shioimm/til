## constant Object::ARGV
- https://docs.ruby-lang.org/ja/2.6.0/method/Object/c/ARGV.htmlO
- Rubyスクリプトを呼び出す時、引数として与えられる配列
```ruby
# コマンドライン引数をチェックする
ARGV.include?('--hoge')
```

## object ENV
- https://docs.ruby-lang.org/ja/2.6.0/class/ENV.html
- 環境変数を表すオブジェクト
- 環境 == システム環境
- 次の2つは同じ処理を示している

```
# シェルで環境変数を設定する
$ HOGE='fuga'
```

```ruby
# Rubyで環境変数を設定する
ENV['MESSAGE'] = 'fuga'
```

- 環境変数はハッシュと同様のインターフェースを持つが、実際にはハッシュではない
  - ハッシュのメソッドは一部使える
```
irb(main):001:0> pp ENV
{"FOO"=>"bar",
 "HOGE"=>"fuga",...
```
