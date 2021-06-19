# Client
- [`http-2/lib/http/2/client.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/client.rb)
- HTTP2::Connectionのサブクラス

## `#receive`
- `Client#send_connection_preface`
  - `@state == :waiting_connection_preface`の場合、SETTINGSフレームにprefaceを設定・ピアへ送信
- `Connection#receive`
