# Connection
- [`http-2/lib/http/2/connection.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/connection.rb)
- Client、Serverへ継承

## `#new_stream`
1. `Connection#activate_stream`
    - `stream = Stream.new`
    - `stream.once` - `:active` / `:close`イベントの購読
    - `stream.on` - `:promise` / `:frame`イベントの購読
2. `@stream_id`の更新

## `#receive`
- 受信したバイト列をHTTP 2.0フレームにデコードし、適切なレシーバーへ転送
1. `@state == :waiting_magic` - TCP接続の合意 -> connection prefaceの送信
    - [HTTP/2 Connection Prefaceの理由と経緯](https://asnokaze.hatenablog.com/entry/20150226/1424962551)
2. `while (frame = @framer.parse(@recv_buffer))`
    - `emit(:frame_received, frame)`
