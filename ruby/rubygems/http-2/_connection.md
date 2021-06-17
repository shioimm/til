# Connection
- [`http-2/lib/http/2/connection.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/connection.rb)
- Client、Serverへ継承

## `#new_stream`
- `Connection#activate_stream`
- `@stream_id`の更新

## `#receive`
- `@state == :waiting_magic` - TCP接続の合意 -> connection prefaceの送信
  - [HTTP/2 Connection Prefaceの理由と経緯](https://asnokaze.hatenablog.com/entry/20150226/1424962551)
  - `@state = :waiting_connection_preface` -> `Connection#settings`
- フレームを読み出し、後続の処理を行う `while (frame = @framer.parse(@recv_buffer))`
  - `emit(:frame_received, frame)`
  - `@continuation`にフレームが含まれている場合の処理 `unless @continuation.empty?`
    - フレームのペイロードをバイナリエンコーディングでラップする
    - フレームのフラグに`:end_headers`を立てる
  - 接続フレームの場合: `connection_management`
  - それ以外の場合: フレームタイプに応じた処理 -> 内部で`Stream#receive`にフレームを渡す
    - `HEADERS` - 内部処理 -> `Stream#receive`↲
    - `PUSH_PROMISE` - 内部処理 -> `Stream#receive`
    - `@streams`にフレームのストリーム番号が含まれる場合:
      - `Stream#receive`
      - `DATA` - `FlowBuffer#update_local_window` -> `FlowBuffer#calculate_window_update`
    - それ以外の場合:
      - `PRIORITY` - `#activate_stream`でストリームを生成 -> `:stream`イベント発信 -> `Stream#receive`
      - `WINDOW_UPDATE` - `FlowBuffer#process_window_update`
      - その他 - `Connection#connection_error`

## `#send`
- `:frame_sent`イベントの発信
- フレームタイプが`DATA`の場合: `FlowBuffer#send_data`
- それ以外の場合: 即座に送信`:frame`イベントの発信
  - フレームタイプが`RST_STREAM`の場合: `Connection#goaway`
  - それ以外の場合: 送信するフレームをバイナリエンコーディングし、フレームごとに`:frame`イベントを発信
    - 実際に送信する操作はユーザーアプリケーションに書く

## `Connection#activate_stream`
- `stream = Stream.new`
- `stream.once` - `:active` / `:close`イベントの購読
- `stream.on` - `:promise` / `:frame`イベントの購読
- `@streams[id] = stream`

## `#settings`
- `@pending_settings << payload`
  -> `send(type: :settings, stream: 0, payload: payload)`
  -> `@pending_settings << payload`

## `#connection_frame?`
- 対象のフレームが接続フレームであるかどうかを確認(SETTINGS, PING, GOAWAY)

## `#connection_management`
- 接続のステート・フレームタイプに応じた処理(接続フレームの場合呼ばれる)
