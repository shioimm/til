# Railsフロントエンド開発に関するメモ (Rails7.0.0時点)
#### アセットパイプラインライブラリ
- sprockets-rails
  - デフォルトでインストールされる
- propshaft
  - `-a propshaft`を指定するとインストールされる
  - propshaftとsprocketsはいずれか一方しかインストールできない
  - sprocketsが必要な他のオプションを指定した場合は`-a propshaft`を指定しても無効
- turbo-rails
  - デフォルトでインストールされる
- stimulus-rails
  - デフォルトでインストールされる

#### JS
- importmap-rails
  - デフォルトでインストールされる
  - `-c`オプションでtailwind以外のCSSフレームワークを指定した場合は`-j importmap`を指定しても無効
  - `node_modules/`ディレクトリは生成されない
- esbuild
  - `-c`オプションでtailwind以外のCSSフレームワークを指定するとjsbundling-rails経由でインストールされる
- rollup
  - `-c`オプションでtailwind以外のCSSフレームワークを指定し、`-j rollup`を指定するとインストールされる
- webpacker
  - `-c`オプションでtailwind以外のCSSフレームワークを指定し、`-j webpack`を指定するとインストールされる

#### CSS
- tailwindcss-rails
  - gemでインストールされる
- tailwind以外のCSSフレームワーク
  - cssbundling-rails経由でインストールされる

## 選択肢
- Propshaft + importmap-rails (デフォルト)
  - Node.js不要
  - トランスパイルなど複雑な設定が必要な場合は別の選択肢に移行する
- Propshaft + jsbundling-rails (+ cssbundling-rails)
  - 任意のバンドラと組み合わせることができる
  - 設定の自由度が高い
  - ホットリロードはできない
- Webpacker
  - Webpackとの統合を提供
  - Propshaftとの共存も可能

#### 移行用の選択肢
- Sprockets + importmap-rails
- Sprockets + jsbundling-rails (+ cssbundling-rails)
- Sprockets + Webpacker

## アセットの変換
#### Sprockets
- /app/assets/javascripts -> /public/assets (`javascript_include_tag`)
- /app/assets/stylesheets -> /public/assets (`stylesheet_link_tag`)
- /app/assets/builds -> /public/assets (`javascript_include_tag`)
- /app/assets/builds -> /public/assets (`stylesheet_link_tag`)

#### Propshaft
- /app/assets/builds -> /public/assets (`javascript_include_tag`)
- /app/assets/builds -> /public/assets (`stylesheet_link_tag`)
- /app/assets/stylesheets -> /public/assets (`stylesheet_link_tag`)

#### importmap-rails + Sprockets
- /app/javascript -> /public/packs (`javascript_import_module_tag`)

#### importmap-rails + Propshaft
- /app/javascript -> /public/packs (`javascript_import_module_tag`)

#### jsbundling-rails
- /app/javascript -> /app/assets/builds

#### cssbundling-rails
- /app/assets/stylesheets -> /app/assets/builds

####  Webpacker
- /app/javascript -> /public/packs (`javascript_pack_tag`)
- /app/javascript/styles -> /public/packs (`stylesheet_pack_tag`)

## 引用
- [Rails 7.0でアセットパイプラインはどう変わるか](https://www.wantedly.com/companies/wantedly/post_articles/354873)
- [Rails 7 : rails newのフロントエンド関連オプションの組み合わせを調べてみた](https://techracho.bpsinc.jp/hachi8833/2021_12_28/114730)
