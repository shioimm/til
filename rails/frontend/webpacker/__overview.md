# Webpacker
- WebpackをRailsのアセットパイプラインとして使うためのブリッジライブラリ

#### Webpakcerが追加するファイル一覧
- `bin/webpack` -> コンパイルを実行するためのバイナリ
- `bin/webpack-dev-server` -> コード変更時にホットリロードを実行するためのバイナリ
- `config/webpacker.yml` -> Webpackerの設定を定義するyamlファイル
- `node_modules/` -> node.jsのモジュール群
- `package.json` -> node.jsの依存関係を記したJSONファイル
- `config/webpack/environment.js` -> プラグインなどの設定ファイル
- `app/javascript/packs/application.js` -> デフォルトのエントリーポイント
  - ディレクトリも同時に生成される

#### 開発で使用するファイル
- 参照: Ruby on Rails 6エンジニア養成読本 Rails 6からのイマドキフロントエンド開発
- `app/javascript/packs/` -> エントリーファイル用ディレクトリ
- `app/javascript/` -> エントリーファイルから読み込まれるモジュール用ディレクトリ
- `config/webpacker.yml` -> Webpackerの設定ファイル
- `config/webpack/**.js` -> 最終的なwebpackの設定を出力するファイル
  - `webpacker.yml`で設定できる範囲外の項目の設定に使用する
- `babel.config.js` -> babel用設定ファイル
  - `.browserlistrc` -> babelでコンパイル対象となるブラウザ環境を設定するファイル

#### `webpack-dev-server`
- 参照: パーフェクトRuby on Rails[増補改訂版] P183
- webpack-dev-server起動時、webpack管理下のファイルの更新が検知され、すぐにビルドを実行する
  - ビルドした結果はwebpack-dev-server以下のメモリ上に展開され、リクエストに応じてファイルとして返される
- webpack-dev-serverの軌道の有無みかかわらずRailsアプリケーションにアクセスできるのは
  Webpacker::DevServerProxyミドルウェアによるもの
  - Webpacker管理下のパス(/pack)配下へアクセスした場合、webpack-dev-serverの起動状態を確認する
  - webpack-dev-serverが起動している場合webpack-dev-server以下のファイルを、
    起動していない場合public/packs配下のファイルを返す

## 参照
- [rails/webpacker](https://github.com/rails/webpacker)
