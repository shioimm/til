# config

```ruby
server_config = {
  :Logger => WEBrick::Log.new($stdout, WEBrick::Log::DEBUG), # ログを標準出力する
}

WEBrick::HTTPServer.new(server_config)
```
