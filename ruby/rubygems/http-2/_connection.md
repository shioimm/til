# Connection
- [`http-2/lib/http/2/connection.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/connection.rb)
- Client、Serverへ継承

## `#new_stream`
- `Connection#activate_stream`
  - `stream = Stream.new`
  - `stream.once` - `:active` / `:close`イベントの購読
  - `stream.on` - `:promise` / `:frame`イベントの購読
- `@stream_id`の更新

## `#receive`
- `@state == :waiting_magic` - TCP接続の合意 -> connection prefaceの送信
  - [HTTP/2 Connection Prefaceの理由と経緯](https://asnokaze.hatenablog.com/entry/20150226/1424962551)
- フレームを読み出し、後続の処理を行う `while (frame = @framer.parse(@recv_buffer))`
  - `emit(:frame_received, frame)`
  - `@continuation`にすでにフレームが含まれている場合の処理 `unless @continuation.empty?`
  - 接続フレームの場合: `connection_management` / 接続フレームでない場合: フレームタイプに応じた処理
    - 内部で`Stream#receive`にフレームを渡す

## `#connection_frame?`
- 対象のフレームが接続フレームであるかどうかを確認(SETTINGS, PING, GOAWAY)

## `#connection_management`
- 接続のステート・フレームタイプに応じた処理(接続フレームの場合呼ばれる)
