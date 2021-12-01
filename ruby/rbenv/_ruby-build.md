# ruby-build
- [ruby-build](http://ruby.studio-kingdom.com/rbenv/ruby_build/)
- `rbenv install`コマンドを提供するプラグイン

```
# /pluginsディレクトリ以下にソースコードをpullする
$ mkdir -p "$(rbenv root)"/plugins
$ cd "$(rbenv root)/plugins"; git clone https://github.com/rbenv/ruby-build.git

# 新しいRubyバージョンをpull
$ cd "$(rbenv root)/plugins/ruby-build"
$ git pull --rebase
```

#### `$ rbenv global x.x.x`でバージョンが切り替わらない場合
1. `$ rbenv rehash`
2. シェルを再起動
3. `$ rbenv version`
  -> `set by`で.ruby-versionが設定されている場合、.ruby-versionファイルの書き換えが必要

## 参照
- [How It Works](https://github.com/rbenv/rbenv/blob/master/README.md#how-it-works)
- [rbenv + ruby-build はどうやって動いているのか](https://takatoshiono.hatenablog.com/entry/2015/01/09/012040)
