# Rack::Builder
- 引用: [rack/lib/rack/builder.rb](https://github.com/rack/rack/blob/master/lib/rack/builder.rb)

## 概要
- Rackアプリケーションを反復的に構築するためのDSLを実装している
  - +use+ -> スタックにミドルウェアを追加する
  - +run+ -> アプリケーションにディスパッチする
  - +map+ -> Rack::URLMapを便利に構築する

## 詳細
- `Rack::Builder#call`によって、このビルダのインスタンスで生成されたRackアプリケーションが呼ばれる
  - Rackアプリケーションは再構築されるたびにウォームアップコード (ある場合) を実行する
