# rbenvの動作
- rbenvはshimをコマンド検索パスの先頭に挿入する

```
$ echo $PATH
/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin

# この場合、.rbenv/shimsは次のようにパスに追加されている
# ~/.rbenv/shims:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
```

- .zshrcに記述されている以下の行が実行されることによって`.rbenv/shims`がパスの先頭に追加される

```
eval "$(rbenv init -)"
```

#### rbenvのインストール先
- Homebrewを使用した場合、`/usr/local/Cellar/rbenv/バージョン番号`


#### `ruby`コマンドの格納場所
- `.rbenv/shims`以下にシンボリックリンクとして配置されている

```
$ sudo which ruby
/.rbenv/shims/ruby
```

#### `ruby`コマンドの実行
1. `ruby`コマンドの実行可能ファイルが探索される
2. コマンド検索パスの先頭にあるrbenv shimが見つかる
3. `ruby`という名前のshimを実行し、`rbenv`にコマンドを渡す

## 参照
- [How It Works](https://github.com/rbenv/rbenv/blob/master/README.md#how-it-works)
- [rbenv + ruby-build はどうやって動いているのか](https://takatoshiono.hatenablog.com/entry/2015/01/09/012040)
- [Choosing the Ruby Version](https://github.com/rbenv/rbenv#choosing-the-ruby-version)
