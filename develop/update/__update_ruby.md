# Ruby バージョンアップメモ
### ①バージョンをどこまで上げるか決定
- [HerokuでサポートされているRubyのバージョン](https://devcenter.heroku.com/articles/ruby-support#ruby-versions)を確認

### ②PRに変更点をまとめる
- リリースノート、CHANGELOGから変更したいバージョンについてまとめる
```
#### 変更点

- 2.6.3
  - https://www.ruby-lang.org/ja/news/2019/04/17/ruby-2-6-3-released/
- 2.6.4
  - https://www.ruby-lang.org/ja/news/2019/08/28/ruby-2-6-4-released/
- 2.6.5
  - https://www.ruby-lang.org/ja/news/2019/10/01/ruby-2-6-5-released/
```

### ②ローカルでRubyのversionを変更
##### ruby-buildを最新版にする
```
$ brew update
$ brew upgrade rbenv ruby-build
```
##### インストールできるRubyのバージョンを確認
```
$ rbenv install -l
```
##### 変更するバージョンをインストール
```
$ rbenv install 2.6.5
```
##### 新しいバージョンを適用
```
$ rbenv local 2.6.5
$ ruby -v
```

### ③.ruby-versionのversionを変更
- 新しいバージョンに書き換える
```
2.6.5
```

### ④Gemfileのversionを変更
- 新しいバージョンに書き換える <--- これがherokuのruby version
```
source 'https://rubygems.org'
ruby '2.6.5'
```
- `bundle install --path vendor/bundle`

### ⑤テストを実行
- rspecを実行

### ⑥.circleci/config.ymlのimageを変更
- [ここ](https://hub.docker.com/r/circleci/ruby/tags)からバージョンを探す
```
docker:
  - image: circleci/ruby:2.6.5-stretch-node-browsers-legacy
```

### ⑦GitHubにpush
- テストが落ちたところを直す

### ⑧review-appで全画面確認
- 正常系・異常系を1回ずつ
- マイナーバージョンを跨ぐ場合、現在のバージョンの最新ビルドバージョンに上げて動作確認した後にマイナーを一つずつ上げていく
```
現在のRubyのバージョンが2.4系だった場合
- 2.4系の最新版にあげる
- 2.5系の最新版にあげる
- 2.6系の最新版にあげる
```

### PRマージ後に共有すること
- 以下の手順を踏んでもらう様に共有
rbenv or anyenv の場合
```
$ rbenv install 2.6.5
$ rbenv local 2.6.5
$ ruby -v
$ bundle install --path vendor/bundle
```
