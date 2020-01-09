### PATHについて
- 参照: [PATHを通すとは？ (Mac OS X)](https://qiita.com/soarflat/items/09be6ab9cd91d366bf71)
- 参照: [PATHを通すために環境変数の設定を理解する (Mac OS X)](https://qiita.com/soarflat/items/d5015bec37f8a8254380)
- PATH = コマンド検索パス
  - シェルがコマンド実行ファイルを探しに行くパス
  - PATHを通す -> コマンド探索パスを追加する
- コマンド探索パスは`$PATH`環境変数に設定されている
```
❯❯❯ echo $PATH
/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
```
- :区切りで複数のパスが登録されている
  - /usr/local/bin
  - /usr/local/sbin
  - /usr/bin
  - /bin
  - /usr/sbin
  - /sbin
- パスは左から右に向かって優先的に探索される

```
# touchコマンドの場合
# binディレクトリにtouchコマンド実行ファイル格納されている
❯❯❯ which touch
/usr/bin/touch
```

```
# rubyコマンドの場合
# .rbenv/shims以下のパスにシンボリックリンクが作られる
❯❯❯ which ruby
/.rbenv/shims/ruby

# rbenvは、shimをコマンド検索パスの先頭に挿入する
# ~/.rbenv/shims:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin
```

```
# 次のコマンドでは、元のコマンド探索パス($PATH)に
# /usr/local/bin(※コマンド実行ファイルのインストール先)を追加している
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
```

### `bin`がつくコマンドとつかないコマンドの違い
```
❯❯❯ which bin/yarn
bin/yarn
❯❯❯ which yarn
/usr/local/bin/yarn
```
- `bin`をつけると今のディレクトリ内のコマンドが呼ばれる
- `bin`をつけないとグローバルなコマンドが呼ばれる

#### `bin`
- 参照: [「/bin」「/usr/bin」「/usr/local/bin」ディレクトリの使い分け](https://linuc.org/study/knowledge/544/)
- 実行可能なプログラムの格納場所(sbinはシステム管理用のプログラムの格納場所)
- `/bin`
  - シングルユーザ(管理者ユーザ)モードで利用するコマンド
- `/usr/bin`
  - シングルユーザモードで利用しないコマンド
  - パッケージ管理システムによってシステムに管理されるコマンドやプログラム(システムを構成する重要なコマンド)
- `/usr/local/bin`
  - シングルユーザモードで利用しないコマンド
  - パッケージ管理システムによってシステムに管理されないコマンドやプログラム(自作のスクリプトなど)
