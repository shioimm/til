# rbenv
## rbenvはどのように動作するか
- 参照: [How It Works](https://github.com/rbenv/rbenv/blob/master/README.md#how-it-works)
- 参照: [rbenv + ruby-build はどうやって動いているのか](https://takatoshiono.hatenablog.com/entry/2015/01/09/012040)

### パス
- `ruby`コマンドは`.rbenv/shims`以下にシンボリックリンクとして存在している
```
$ sudo which ruby
/.rbenv/shims/ruby
```

- rbenvは、shimをコマンド検索パスの先頭に挿入する
```
$ echo $PATH
/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin

# この場合、.rbenv/shimsは次のようにパスに追加されている
# ~/.rbenv/shims:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
```

- 具体的には、.zshrcに記述されている以下の行が実行されることによって`.rbenv/shims`がパスの先頭に追加される
```
eval "$(rbenv init -)"
```

### 実行
- `ruby`コマンドは下記のように実行される
  - `ruby`コマンドの実行可能ファイルが探索される
  - コマンド検索パスの先頭にあるrbenv shimが見つかる
  - `ruby`という名前のshimを実行し、`rbenv`にコマンドを渡す

### バージョン探索優先順
- (1) `RBENV_VERSION`環境変数で指定されたバージョン
  - rbenvシェルコマンドを使用して、現在のシェルセッションでこの環境変数を設定することができる
- (2) 最初に見つかった`.ruby-version`に記述されているバージョン
  - 実行中のスクリプトのディレクトリと、その各親ディレクトリからファイルシステムのルートまで検索した際に見つかった順
  - `$ rbenv local`コマンドによって現在のディレクトリにruby-versionファイルを作成することができる
- (3) `~/.rbenv/version`で指定されたバージョン
  - `$ rbenv global`コマンドによって変更できる
  - `~/.rbenv/version`が存在しない場合、
    rbenvはシステムRuby(rbenvがパスにない場合に実行されるバージョン)を使用する
- Rubyの各バージョンは、`~/.rbenv/versions`以下にインストールされる

### rbenvのインストール先
- Homebrewを使用した場合、 rbenvは`/usr/local/Cellar/rbenv/バージョン番号`

### プラグイン
- `rbenv`のコマンドはプラグイン方式になっている
- プラグインは`~/.rbenv/plugins/`以下に配置される

#### ruby-build
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

- `$ rbenv global x.x.x`でバージョンが切り替わらない場合:
  - `$ rbenv rehash`
  - シェルを再起動
  - `$ rbenv version`
    -> `set by`で`.ruby-version`が設定されている場合、バージョンの書き換えが必要

## gemコマンド
### `$ gem env`
- Ruby Gemsの実行環境を確認できる
  - `GEM PATH`にgemが格納されている

### `$ gem list`
- インストールしているgemのバージョン一覧
- `$ gem list xxx`
  - ローカルにインストールしているgem xxxのバージョン
- `$ gem list xxx -re`
  - Rubygemsのgem xxxのバージョン
- `$ gem list xxx -rea`
  - Rubygemsのgem xxxのすべてのバージョン一覧
