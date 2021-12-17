# 定数
## 定数探索の優先順
1. 現在の名前空間
2. 現在の名前空間を囲むレキシカルな名前空間
3. 現在の名前空間の継承ツリー
4. 現在の名前空間を囲むレキシカルな名前空間の継承ツリーは探索しない
- 参照: 研鑽Rubyプログラミング

## 組み込み定数
#### ARGV
- [constant Object::ARGV](https://docs.ruby-lang.org/ja/3.0.0/method/Object/c/ARGV.html)
- Rubyスクリプトを呼び出す時、引数として与えられる配列

```ruby
# コマンドライン引数をチェックする
ARGV.include?('--hoge')
```

#### ENV
- [object ENV](https://docs.ruby-lang.org/ja/3.0.0/class/ENV.html)
- システム環境変数を表すオブジェクト

```
# シェルで環境変数を設定する
$ HOGE='fuga'
```

```ruby
# Rubyで環境変数を設定する
ENV['MESSAGE'] = 'fuga'
```

- ENVはハッシュと同様のインターフェースを持つが、実際にはハッシュではない
  - ハッシュのメソッドは一部使える

```
irb(main):001:0> pp ENV
{"FOO"=>"bar",
 "HOGE"=>"fuga",...
```
