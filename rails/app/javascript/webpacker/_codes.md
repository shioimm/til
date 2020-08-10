# 実装
## 既存のアプリケーションにreactを追加したい
```sh
$ /bin/rails webpacker:install:react
```

### AssetsPathにnode_modulesを追加したい
```ruby
# config/initializers/assets.rb
Rails.application.config.assets.paths << Rails.root.join('node_modules')
```

## WebpackerでFontAwesomeを使いたい
- 参照: [Rails 5.2 + webpacker で FontAwesome 5 を利用する](https://qiita.com/fukmaru/items/427b43bd02a0b812212c)

1. yarnにFontAwesomeを追加
```
$ yarn add @fortawesome/fontawesome-free
```

2. `app/javascripts/src/application.scss`でFontAwesomeを読み込む
```scss
$fa-font-path: '~@fortawesome/fontawesome-free/webfonts';
@import '~@fortawesome/fontawesome-free/scss/fontawesome';
@import '~@fortawesome/fontawesome-free/scss/regular';
@import '~@fortawesome/fontawesome-free/scss/solid';
```

3. `app/javascript/packs/application.js`(エントリーポイント)に↑を読み込む
```js
import '../src/application.scss'
```

4. レイアウトで`javascript_pack_tag`を読み込む
```haml
= javascript_pack_tag 'application'
= javascript_pack_tag 'common'
```
- config/webpacker.ymlで`extract_css: true`が設定されている場合、
application.jsとapplications.cssがそれぞれ独立したファイルとしてmanifest.jsonに読み込まれるため、
別途`stylesheet_pack_tag`も読み込みが必要
  - `extract_css: false`の場合は`javascript_pack_tag`でcssも読み込まれるため以下は不要
```haml
= javascript_pack_tag 'application'
= javascript_pack_tag 'common'
- # 以下は本番環境で必要
- # (config/webpacker.ymlにてextract_css: trueのため、JSとcssが独立したファイルとして読み込まれる)
= stylesheet_pack_tag 'application

- # 上記のコードで開発環境(`extract_css: false`)においてconsoleにエラーが出ない理由:
- # 以下の箇所でエラーではなくnilが返るため
- # webpacker/lib/webpacker/helper.rb:37
- ##   # When extract_css is true in webpacker.yml or the file is not a css:
- ##   <%= asset_pack_url 'calendar.css' %> # => "http://example.com/packs/calendar-1016838bab065ae1e122.css"
- # def asset_pack_url(name, **options)
- #   if current_webpacker_instance.config.extract_css? || !stylesheet?(name)
- #     asset_url(current_webpacker_instance.manifest.lookup!(name), **options)
- #   end
- # end
```

5. FontAwesomeを使用する
- `app/javascript/`以下で使用する場合
  - 使用するフォントをimportする
  - `<i>`タグにクラスを与える
```js
import fontawesome from '@fortawesome/fontawesome'
```
- `app/views`以下で使用する場合
  - `<i>`タグにクラスを与えるだけ

## `chosen_rails`を廃止してnode_modulesに`chosen-js`を追加したい
- 参照: [Rails 5: Webpacker公式README — Webpack v4対応版（翻訳](https://techracho.bpsinc.jp/hachi8833/2018_05_24/56977)

1. `yarn add chosen``yarn add chosen-js`を実行
2. app/javascript以下に設定ファイルを置く
  - app/javascripts/packs -> エントリーポイント
    - application.js -> `import 'chosen-js'``import 'chosen-js/chosen.min.css'`
  - app/javascript/src
    - application.scss -> `@import 'chosen-js'`
3. app/views/layoutsでpacksを読み込む
```ruby
# javascript_include_tag 'application' で定義されるjQueryをjavascript_pack_tagで使用するため、
# javascript_include_tagを先に読み込む
<%= javascript_include_tag 'application', 'data-turbolinks-track' => 'reload', defer: true %>
<%= javascript_pack_tag 'application', defer: true %>
```
4. app/assets/javascripts/application.js / app/assets/stylesheets/application.scss から`chosen`の記述を削除
5. Gemfileから`chosen_rails`を削除して`bundle install`
6. サーバーを再起動して動作確認(動作しないようならtmp/cacheをrmしてもう一度再起動)
