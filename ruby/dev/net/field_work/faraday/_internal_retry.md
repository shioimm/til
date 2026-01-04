# faraday 現地調査 (faraday-retry-2.4.0時点)
## 気づいたこと
- ミドルウェアを利用する必要あり

## リトライの設定

```ruby
Faraday.new("https://example.com") do |conn|
  conn.request :retry, # => RackBuilder#request
               max: 3,                   # 最大リトライ回数
               interval: 0.5,            # 初期待機時間(s)
               interval_randomness: 0.5, # ジッタ
               backoff_factor: 2,        # 指数バックオフ
               exceptions: [             # 対象エラー
                 Faraday::ConnectionFailed
               ]

  conn.adapter Faraday.default_adapter
end
```

## リトライの実行
