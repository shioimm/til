# 設定
- 参照: パーフェクトRuby on Rails[増補改訂版] P186-187

## loaderの追加
```
$ bin/rails webpacker:install:xxx(追加したいloader)
```
- `config/webpack/loaders/xxx.js`が追加される
- `config/webpack/environment.js`に以下の行が追加される
```js
const xxx = require('./loaders/xxx')
environment.loaders.prepend('xxx', xxx)

// environment`は`config/webpack/動作環境.js`内で
// environment.toWebpackConfig()`されて最終的な設定用のオブジェクトとなる
```

## pluginの追加
### ProvidePluginの追加
- 明示的な`require`をせずライブラリをグローバルに読み込む
  - 参照: [ProvidePlugin](https://webpack.js.org/plugins/provide-plugin/)
```js
// config/webpack/plugins/provide.js

const webpack = require('webpack')
module.exports = new webpack.ProvidePlugin({
  xxx: 'xxx', // ライブラリを一意に示す名前をつける
});
```
- `config/webpack/environment.js`に以下の行を追加する
```js
const provide = require('./plugins/provide')
environment.loaders.prepend('provide', provide)
```
