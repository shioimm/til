# `gem`コマンド
## `.gemrc`(設定ファイル)
```
install: "--document=yri" # installコマンド実行時のオプション
update: "--no-document" # updateコマンド実行時のオプション
```

## オプション
- [Guides](https://guides.rubygems.org/command-reference/#gem_environment)

| オプション      | 意味                                                              |
| -               | -                                                                 |
| `open`          | gemのソースをエディタで開く(`GEM_EDITOR`変数を設定しておく)       |
| `pristine`      | インストール済みのgemをgem cacheの状態から元に戻す                |
| `which`         | インストール済みのgemのパス                                       |
| `environment`   | gemのインストール先ディレクトリ (`$ gem environment gemdir`)      |
| `env`           | Ruby Gemsの実行環境を確認できる (`GEM PATH`にgemが格納されている) |
| `list`          | インストールしているgemのバージョン一覧                           |
| `list xxx`      | ローカルにインストールしているgem xxxのバージョン                 |
| `list xxx -re`  | Rubygemsのgem xxxのバージョン                                     |
| `list xxx -rea` | Rubygemsのgem xxxのすべてのバージョン一覧                         |
