# Rack::Server
- 引用: [rack/lib/rack/server.rb](https://github.com/rack/rack/blob/master/lib/rack/server.rb)

## 概要
### `Rack::Server.start`
- 新しいRackサーバーを起動する -> `$ rackup`の実行
- ARGVを解析し、標準のARGV rackupオプションを提供する
- デフォルトで`config.ru`をロードする
