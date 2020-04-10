# Rack::BodyProxy
- 引用: [rack/lib/rack/body_proxy.rb](https://github.com/rack/rack/blob/master/lib/rack/body_proxy.rb)

## 概要
- レスポンスボディのためのプロキシ
  - レスポンスボディが閉じたときにブロックを呼び出すことを可能にする
  - レスポンスがクライアントに対して完全に送信された後、
    レスポンスの本文をラップしブロックを呼び出すように設定する
