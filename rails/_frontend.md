# Railsフロントエンド開発に関するメモ(Rails6.0.1時点)
- Railsは`app/javascript/assets`(Webpacker)と`app/assets/assets`(Sprockets)両方のアセッツをプリコンパイルする

### 構成要素
- 参照: [How to write Javascript in Rails 6 | Webpacker, Yarn and Sprockets](https://blog.capsens.eu/how-to-write-javascript-in-rails-6-webpacker-yarn-and-sprockets-cdf990387463)
- 参照: [Rails 6+Webpacker開発環境をJS強者ががっつりセットアップしてみた（翻訳）](https://techracho.bpsinc.jp/hachi8833/2019_11_28/83678)

#### JSパッケージマネージャー
- npm -> node.jsパッケージマネージャー
- yarn -> npmより新しいnode.jsパッケージマネージャー
  - npmリポジトリからパッケージを探す
  - `yarn.lock`でバージョンを固定する(`Gemfile.lock`と同じ)
    - npmは`package-lock.json`でバージョンを固定する機能が追加された
  - npm / yarn自体はOSでバージョン管理を行う(ex. brewで入れた場合はbrewで管理)
- `/node_modules` -> ダウンロードされたパッケージ本体
- `package.json` -> ダウンロードされたパッケージのリスト(`Gemfile`と同じ)
- nodebrew、nvm、nbenv -> node.jsバージョン管理システム

#### Babel
- ES6未対応のブラウザに対して、プロダクトコードのES6をES5へ変換するコンパイラ

#### Webpack
- アセッツコンパイルや管理を自動化する
  - Babelを使ってES6 -> ES5への変換を行う
  - 生成されたpackをファイルに出力し、DOMに含める

### Webpacker 4.2.0
- 仮想DOMの世界
- RailsアプリケーションにWebpackを組み込むgem
  - `yarn`で追加したパッケージを`require`する
- 事前に設定されたWebpackにビューヘルパーを加えたものを提供することで生成されたアセットを対応付けられるようにする
- Railsに導入時点で設定ファイルが含まれている
  - 例: `app/javascript/packs/application.js` -> エントリーポイント
  - 例: `<%= javascript_pack_tag 'application' %>`
- エントリーポイントから生成されたコンパイル済みのJSファイルパスをWebpackerから取得
- HTMLはpackに含まれるものに直接アクセスできない
- `app/javascript/packs`以下のファイルを読み込む
  - css
    - `stylesheet_pack_tag`ヘルパーを使用
  - JS
    - `javascript_pack_tag`ヘルパーを使用
    - レンダリング前にDOMを操作する目的で使用される(Reactなど)

#### Railsで使用するファイル
- 参照: Ruby on Rails 6エンジニア養成読本 Rails 6からのイマドキフロントエンド開発
- `app/javascript/packs/` -> エントリーファイル用ディレクトリ
- `app/javascript/` -> エントリーファイルから読み込まれるモジュール用ディレクトリ
- `config/webpacker.yml` -> Webpackerの設定ファイル
- `config/webpack/**.js` -> 最終的なwebpackの設定を出力するファイル
  - `webpacker.yml`で設定できる範囲外の項目の設定に使用する
- `babel.config.js` -> babel用設定ファイル
  - `.browserlistrc` -> babelでコンパイル対象となるブラウザ環境を設定するファイル

### Sprockets 4.0.0
- DOMの世界
- Railsに元々入っていたアセットパイプライン
  - gemをインストールし、`app/assets/application.js`でライブラリを`require`する
- Rails6(Sprockets4)以降は主にCSSをアセッツとして扱うために使用する
  - `app/assets/config/manifest.js`にCSSへのリンクを記述する
  - `<%= stylesheet_link_tag 'application' %>`
- Sprocketsは関数をコンパイルする(グローバルスコープでアクセスできる)
- HTMLはJSファイルに含まれるものにアクセスできる(変数、関数etc)
- `app/assets`以下のファイルを読み込む
  - css
    -  `stylesheet_link_tag`ヘルパーを使用
  - JS
    - `javascript_include_tag`ヘルパーを使用
    - レンダリング後にDOMを操作する目的で使用される(jQueryなど)

### 読込例
```haml
= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track' => "reload"
= javascript_include_tag 'application', 'data-turbolinks-track' => 'reload', defer: true
= javascript_pack_tag 'application', defer: true
= stylesheet_pack_tag 'application'
= javascript_pack_tag 'common'
= stylesheet_pack_tag 'common'
```
- \<script\>タグの`defer`属性
  - 参照: [\<script\> タグに async / defer を付けた場合のタイミング](https://qiita.com/phanect/items/82c85ea4b8f9c373d684)
  - HTMLのパースと非同期にJSのダウンロードを行い、パースが終わったタイミングでJSを実行する
    - デフォルトではHTMLパース、JSのダウンロード、パースを順次実行する
    - JSのダウンロードが非同期に行われるため表示速度が速い
  - ここでは`javascript_include_tag` `javascript_pack_tag`両方に`defer`がついており、
  JSの実行順が担保されない
- `common`
  - 共通のモジュールをバンドルしたファイル
  - 参照: [なぜoptimization.splitChunksを有効にするのか](https://qiita.com/soarflat/items/1b5aa7163c087a91877d#%E3%81%AA%E3%81%9Coptimizationsplitchunks%E3%82%92%E6%9C%89%E5%8A%B9%E3%81%AB%E3%81%99%E3%82%8B%E3%81%AE%E3%81%8B)

## アセットパイプラインの環境による違い
- 参照: 現場で使える Ruby on Rails 5速習実践ガイド
- アセットパイプラインの役割
  - コンパイル
  - アセットの連結
    - マニフェストファイルに基づく
      - app/assets/javascripts/application.js
      - app/assets/stylesheets/application.css
  - アセットの最小化
  - ダイジェスト付与
- development
  - コンパイル・ダイジェスト付与を自動的に行う
  - アセットの連結・最小化を行わない
    - アセットの連結を行わないためJSファイルとCSSファイルはファイル数分読み込まれる
- production
  - アセットプリコンパイル(手動)によりアセットパイプラインのすべての処理を行う
    - アセットの連結によりJSファイルとCSSファイルは各一つずつ読み込まれる
