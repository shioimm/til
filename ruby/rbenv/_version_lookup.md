# バージョン探索優先順
#### (1) `RBENV_VERSION`環境変数に指定されているバージョン
- 現在のシェルセッションで有効なバージョンとして環境変数にバージョンを指定する
- `$ rbenv shell`コマンドで変更可能

```
$ rbenv shell x.x.x
```

#### (2) .ruby-versionに記述されているバージョン [1]
- 実行中のスクリプトのディレクトリを起点として親ディレクトリからファイルシステムのルートまで検索し、
  最初に見つかった`.ruby-version`ファイルに記述されているバージョン

#### (3) .ruby-versionに記述されているバージョン [2]
- current working dirを起点として親ディレクトリからファイルシステムのルートまで検索し、
  最初に見つかった`.ruby-version`ファイルに記述されているバージョン
- `$ rbenv local`コマンドで変更可能

```
$ rbenv local x.x.x
```

#### (3) ~/.rbenv/versionに指定されているバージョン
- システムにおいてグローバルな~/.rbenv/versionファイルに記述されているバージョン
- Rubyの各バージョンは、~/.rbenv/versions以下にインストールされる
- `$ rbenv global`コマンドで変更可能

```
$ rbenv global x.x.x
```

#### (4) "system" Ruby
- rbenvがパスに含まれていない場合に実行されるバージョン

## 参照
- [How It Works](https://github.com/rbenv/rbenv/blob/master/README.md#how-it-works)
- [rbenv + ruby-build はどうやって動いているのか](https://takatoshiono.hatenablog.com/entry/2015/01/09/012040)
- [Choosing the Ruby Version](https://github.com/rbenv/rbenv#choosing-the-ruby-version)
