## 環境構築時に実行したこと

### 環境整備
- Xcodeをインストール(App store)
- コマンドラインツールをインストール
```shell
$ xcode-select --install
```
- Homebrewをインストール
```shell
$ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
- Homebrewでrbenv、postgresql、nodebrew、yarn、redis、vimをインストール
```shell
// brew updateで最新状態を確認してから
$ brew install rbenv
$ brew install postgresql
$ brew install node@8
$ brew install yarn
$ brew install redis
$ brew install vim
```
- nodebrewでnodeをインストール
```shell
$ nodebrew setup

// インストールできるバージョンの確認
$ nodebrew ls-remote

// インストールしたいバージョンをインストール
$ nodebrew install v10.14.0
```
- シェルをzshに変更
- vimの設定を行う

### GitHubの環境整備
- ローカルに秘密鍵と公開鍵を作成してssh-agentに登録
```shell
// .ssh/
$ ssh-keygen
// デフォルトでrsaになる
// 名前はgithub_rsaに変更

$ ssh-add -K ~/.ssh/github_rsa
```
- ~/.ssh/configを作成
```
// .ssh/config
Host github
  HostName github.com
  IdentityFile ~/.ssh/github_rsa
  User git
```
- GitHubに公開鍵を登録(`cat ~/.ssh/github_rsa.pub`)
- 疎通確認(`ssh -T github`)

### 作業リポジトリの準備
```shell
$ cd ~/WORK_DIRECTORY
$ git clone 作業リポジトリ
$ cd 作業ディレクトリ
```

### データベースの準備
```
// PGを起動
$ pg_ctl -D /usr/local/var/postgres start

// 終了時は以下のようにする
$ pg_ctl -D /usr/local/var/postgres stop
```
```
// 現在のユーザーを確認
$ psql -q -c'select * from pg_user' postgres

$ createuser database.yaml指定のusername

// ユーザーにスーパーユーザーの権限を付与する
// 現在のテーブルを確認
$ psql -l
// 初期データベースのpostgresに入る
$ psql -d postgres

// ユーザーをsuにする
postgres=# ALTER ROLE database.yaml指定のusername WITH SUPERUSER CREATEDB

// ユーザーのusesuperが"t"になっていることを確認
$ psql -q -c'select * from pg_user' postgres
```

### 開発の準備
```
// gemインストール
$ bundle install --path vendor/bundle

// 開発用データベース作成
$ bin/rails db:create
$ bin/rails db:migrate RAILS_ENV=development

// 処理データ投入
$ rake db:seed_fu

// サーバー起動
$ rails s

// Sidekiq起動
$ redis-server
$ bundle exec sidekiq -C config/sidekiq.yml -d
```

### 参照した記事
- [Rails Girls インストール・レシピ](http://railsgirls.jp/install)
- [お前らのターミナルはダサい](https://qiita.com/kinchiki/items/57e9391128d07819c321)
- [脱初心者を目指すVimmerにオススメしたいVimプラグインや.vimrcの設定](https://qiita.com/jnchito/items/5141b3b01bced9f7f48f)
- [【Github, SSH】SSH鍵を作成し、Githubへそれを登録する手順](https://qiita.com/knife0125/items/50b80ad45d21ddec61a9)
- [ssh-agentを利用して、安全にSSH認証を行う](https://qiita.com/naoki_mochizuki/items/93ee2643a4c6ab0a20f5)
- [nodebrewでnodeのバージョンを切り替える方法](https://qiita.com/kuriya/items/36ae29366df0b7c95dec)
- [MacのRails5開発でPostgreSQL導入とエラー解決法](https://www.inodev.jp/entry/mac-rails-postgresql)
