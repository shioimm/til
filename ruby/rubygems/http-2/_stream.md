# Stream
- [`http-2/lib/http/2/stream.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/stream.rb)

## `#initialize`
  - インスタンス変数の初期化
  - 優先度の設定
  - `:window` / `:local_window`イベントの購読

## `#receive`
- `Stream#transition`
- フレームタイプ別の処理とイベントコール
- `Stream#complete_transition`

### フレームタイプ
- `:data`
  - `FlowBuffer#update_local_window`
  - `FlowBuffer#calculate_window_update`
- `:headers`
- `:push_promise`
- `:priority`(イベントコールなし)
  - `Stream#process_priority`
  - イベントコールなし
- `:window_update`(イベントコールなし)
  - `FlowBuffer#process_window_update`
- `:altsvc`
- `:blocked`

## `#send`
- `Stream#process_priority`
- フレームタイプ別の処理とイベントコール

### フレームタイプ
- `:data`
  - `FlowBuffer#send_data`
- `:window_update`
  - `Stream#manage_state`(ローカルウィンドウサイズのインクリメント・イベントコール)
- その他
  - `Stream#manage_state`(イベントコール)

## `#headers`
- オプション`end_headers`、`end_stream`を`flags`に格納
- HEADERフレームの送信 `send(type: :headers, flags: flags, payload: headers)`

## `data`
- オプション`end_stream`を`flags`に格納
- DATAフレームの送信 `send(type: :data, flags: flags, payload: payload)`
  - `payload.bytesize > max_size`の場合はデータをチャンク化する
