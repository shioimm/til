# Ruby バージョンアップメモ
### ①バージョンをどこまで上げるか決定
- [HerokuでサポートされているRubyのバージョン](https://devcenter.heroku.com/articles/ruby-support#ruby-versions)を確認

### ②PRに変更点をまとめる
- リリースノート、CHANGELOGから変更したいバージョンについてまとめる
```
#### 変更点

- x.x.a
  - https://www.ruby-lang.org/ja/news/2019/04/17/ruby-2-6-3-released/
- x.x.b
  - https://www.ruby-lang.org/ja/news/2019/08/28/ruby-2-6-4-released/
- x.x.c
  - https://www.ruby-lang.org/ja/news/2019/10/01/ruby-x.x.a-released/
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
$ rbenv install x.x.a
```

### ③ローカルで新しいバージョンを適用
```
$ rbenv local x.x.a
$ ruby -v
```

- .ruby-versionのversionを直接変更しても良い
```
x.x.a
```

### ④Gemfileのversionを変更
- 新しいバージョンに書き換える <--- これがherokuのruby version
```
source 'https://rubygems.org'
ruby 'x.x.a'
```
- `bundle install --path vendor/bundle`

### ⑤テストを実行
- rspecを実行

### ⑥.circleci/config.ymlのimageを変更
- [ここ](https://hub.docker.com/r/circleci/ruby/tags)からバージョンを探す
- `- image: circleci/ruby:`以下を修正
```
docker:
  - image: circleci/ruby:x.x.a-node-browsers-legacy
```
- 参照: [言語イメージのバリアント](https://circleci.com/docs/ja/2.0/circleci-images/#%E8%A8%80%E8%AA%9E%E3%82%A4%E3%83%A1%E3%83%BC%E3%82%B8%E3%81%AE%E3%83%90%E3%83%AA%E3%82%A2%E3%83%B3%E3%83%88)

### ⑦GitHubにpush
- テストが落ちたところを直す

### ⑧review-appで全画面確認
- 正常系・異常系を1回ずつ

### その他
- マイナーバージョンを跨ぐ場合、現在のバージョンの最新ビルドバージョンに上げて動作確認した後にマイナーを一つずつ上げていく
```
現在のRubyのバージョンが2.5系だった場合
- 2.5系の最新版にあげる
- 2.6系の最新版にあげる
- 2.7系の最新版にあげる
```

#### PRマージ後に共有すること
- 以下の手順を踏んでもらう様に共有
rbenv or anyenv の場合
```
$ rbenv install x.x.a
$ rbenv local x.x.a
$ ruby -v
$ bundle install --path vendor/bundle
```
