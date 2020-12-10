## `chosen_rails`を廃止してnode_modulesに`chosen-js`を追加したい
- 参照: [Rails 5: Webpacker公式README — Webpack v4対応版（翻訳](https://techracho.bpsinc.jp/hachi8833/2018_05_24/56977)

1. `chosen` / `chosen-js`を追加
```sh
$ yarn add chosen
$ yarn add chosen-js
```

2. `app/javascript`以下に設定ファイルを置く
  - `app/javascripts/packs` -> エントリーポイント
    - `application.js` -> `import 'chosen-js'` / `import 'chosen-js/chosen.min.css'`
  - `app/javascript/src`
    - `application.scss` -> `@import 'chosen-js'`

3. `app/views/layouts`でpacksを読み込む
```ruby
# javascript_include_tag 'application' で定義されるjQueryをjavascript_pack_tagで使用するため、
# javascript_include_tagを先に読み込む

<%= javascript_include_tag 'application', 'data-turbolinks-track' => 'reload', defer: true %>
<%= javascript_pack_tag 'application', defer: true %>
```

4. `app/assets/javascripts/application.js` / `app/assets/stylesheets/application.scss` から`chosen`の記述を削除

5. Gemfileから`chosen_rails`を削除して`$ bundle install`

6. サーバーを再起動して動作確認(動作しないようなら`tmp/cache`を`rm`してもう一度再起動)
