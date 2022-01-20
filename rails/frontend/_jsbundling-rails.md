# jsbundling-rails
#### 機能
- esbuild、rollup.js、Webpackに必要な基本的な設定の提供
- 選択したバンドラの基本的な依存関係の解決
- 必要に応じた設定ファイルの作成
- `assets:precompile`実行時に`yarn install && yarn build`の実行、
  `app/javascripts`以下のソースのコンパイル、
  `app/assets/builds`への出力を行う

#### ビルド
1. JSソースをapp/javascriptに置く
    - デフォルトのエントリーポイントはapp/javascript/application.js
2. package.json定義でビルドスクリプトを実行する
3. 最終的なビルドをapp/assets/buildsのアセットパイプラインに渡す

### タスク
#### インストール
```
$ ./bin/rails javascript:install:webpack
```

- コンパイル済みファイルを置くためのapp/assets/builds/ディレクトリを追加
- package.jsonをビルドするためのエントリーポイントとなるapp/javascript/application.jsを追加
- app/assets/config/manifest.jsに`//= link_tree ../builds`を追加
- .gitignoreに`/app/assets/builds/*`を追加
- foremanのセットアップ
  - bin/devコマンドの追加
  - Procfile.devファイルの追加
- webpack.config.jsの作成 (jsbundling-railsによるデフォルト設定が記載済み)
- package.jsonにビルドスクリプトを追加 (またはwebpack / webpack-cliのアップデート)


#### ビルド
```
$ yarn build --progress --color
```

```json
// package.json
{
  "scripts": {
    "build": "webpack --config webpack.config.js", // 追加
    ...
  },
  ...
}
```

#### サーバー起動
```
$ ./bin/dev
```

- `$ rails server` & `$ yarn build --watch` (Foremanを使用)

## 参照
- [jsbundling-rails](https://github.com/rails/jsbundling-rails)
- [Rails 7 will have three great answers to JavaScript in 2021+](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b)
- [Comparison with webpacker](https://github.com/rails/jsbundling-rails/blob/8b4d2a95bc4bf5c5d590813242ac8f0aee0567fc/docs/comparison_with_webpacker.md)
- [Switch from Webpacker 5 to jsbundling-rails with webpack](https://github.com/rails/jsbundling-rails/blob/main/docs/switch_from_webpacker.md)
