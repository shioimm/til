# rbenv

## rbenvはどのように動作するか
- 参照: [How It Works](https://github.com/rbenv/rbenv/blob/master/README.md#how-it-works)
- 参照: [rbenv + ruby-build はどうやって動いているのか](https://takatoshiono.hatenablog.com/entry/2015/01/09/012040)

### パス
#### 例: `ruby`コマンド
- `ruby`コマンドは.rbenv/shims以下にシンボリックリンクとして存在している
```
❯❯❯ which ruby
/.rbenv/shims/ruby
```

- rbenvは、shimをコマンド検索パスの先頭に挿入する
```
❯❯❯ echo $PATH
/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin

# この場合、.rbenv/shimsは次のようにパスに追加されている
# ~/.rbenv/shims:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
```

- 具体的には、.zshrcに記述されている以下の行が実行されることによって`.rbenv/shims`がパスの先頭に追加される
```
eval "$(rbenv init -)"
```

### 実行
- rubyコマンドは下記のように実行される
  - rubyコマンドの実行可能ファイルが探索される
  - コマンド検索パスの先頭にあるrbenv shimが見つかる
  - rubyという名前のshimを実行し、rbenvにコマンドを渡す

### バージョン
- Rubyバージョンは次の優先順に指定されている
  - 1.RBENV_VERSION環境変数で指定されたバージョン
    - rbenvシェルコマンドを使用して、現在のシェルセッションでこの環境変数を設定することができる
  - 2.最初に見つかった.ruby-versionに記述されているバージョン
    - 実行中のスクリプトのディレクトリと、その各親ディレクトリからファイルシステムのルートまで検索した際に見つかった順
    - `rbenv local`コマンドによって現在のディレクトリにruby-versionファイルを作成することができる
  - 4.~/.rbenv/versionで指定されたバージョン。
    - `rbenv global`コマンドによって変更できる
    - ~/.rbenv/versionが存在しない場合、rbenvは「システム」Ruby(rbenvがパスにない場合に実行されるバージョン)を使用する

- 各Rubyのバージョンは、~/.rbenv/versions以下にインストールされる

### rbenvのインストール先
- homebrewを使用した場合、以下の場所にインストールされる
  - rbenv は /usr/local/Cellar/rbenv/バージョン番号
  - ruby-build は /usr/local/Cellar/ruby-build/バージョン番号(年月日)

### プラグイン
- rbenv のコマンドはプラグイン方式になっている
  - 例: `rbenv install` -> ruby-build
- プラグインは~/.rbenv/pluginsに配置される
