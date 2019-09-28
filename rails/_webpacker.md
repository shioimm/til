## Webpacker
#### AssetsPathにnode_modulesを追加する
```ruby
# config/initializers/assets.rb
Rails.application.config.assets.paths << Rails.root.join('node_modules')
```

#### `chosen_rails`を廃止してnode_modulesに`chosen`を追加する
- 参照: [Rails 5: Webpacker公式README — Webpack v4対応版（翻訳](https://techracho.bpsinc.jp/hachi8833/2018_05_24/56977)

1. `yarn add chosen-js`を実行
2. app/javascript以下に設定ファイルを置く
  - app/javascripts/packs -> エントリーポイント
    - application.js -> `chosen-js``chosen-js/chosen.min.css`をimportする
  - app/javascript/src
    - application.scss -> `chosen-js`を@importする
3. app/views/layoutsでpacksを読み込む
```ruby
<%= javascript_pack_tag 'application' %>
<%= stylesheet_pack_tag 'application' %>
```
4. app/assets/javascripts/application.js / app/assets/stylesheets/application.scss から`chosen`の記述を削除
5. Gemfileから`chosen_rails`を削除して`bundle install`
