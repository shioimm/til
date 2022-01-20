# Webpack
- Node.jsベースのアセットパイプライン

#### 機能
- モジュールバンドリング
  - モジュール形式としてES Modules / CommonJS Modulesをサポート
- CSSバンドリング
- トランスパイル
  - 別途babel-loaderなどのローダーが必要
  - webpack.config.jsにて設定を行う
- 最小化と難読化
- webpack-dev-server

## webpack.config.js
- mode - 動作環境
- entry - エントリーポイント
- output - バンドルされたファイルの出力先・出力ファイル名
- modules
  - rules
    - test - 解釈するファイル
    - exclude - 対象外とするファイル
    - use - 使用するモジュール
- plugins - プラグインの追加

## 参照
- [Webpack](https://webpack.js.org/)
- [webpack/webpack](https://github.com/webpack/webpack)
- [Rails 7.0でアセットパイプラインはどう変わるか](https://www.wantedly.com/companies/wantedly/post_articles/354873)
