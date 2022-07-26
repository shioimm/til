# Rubyアップデート
### 準備
- ドキュメントを参照して変更内容を確認する

### Rubyのアップデート
```
$ cd "$(rbenv root)/plugins/ruby-build"
$ git pull --rebase
$ rbenv install *.*.*
$ rbenv local   *.*.* # (.ruby-versionの更新)
```

#### 開発環境のアップデート
- Gemfileを更新 -> `$ bundle install`
- CIのイメージを更新
- `$ bundle exec rspec`
- `$ bundle exec rubocop`
