# Stream
- [`http-2/lib/http/2/stream.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/stream.rb)

## `#initialize`
1. インスタンス変数の初期化
2. 優先度の設定
3. `:window` / `:local_window`イベントの購読

## `#receive`
1. `Stream#transition`
2. フレームタイプ別の処理とイベントコール
3. `Stream#complete_transition`

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
1. `Stream#process_priority`
2. フレームタイプ別の処理とイベントコール

### フレームタイプ
- `:data`
  - `FlowBuffer#send_data`
- `:window_update`
  - `Stream#manage_state`(ローカルウィンドウサイズのインクリメント・イベントコール)
- その他
  - `Stream#manage_state`(イベントコール)

## `#headers`
1. オプション`end_headers`、`end_stream`を`flags`に格納
2. HEADERフレームの送信 `send(type: :headers, flags: flags, payload: headers)`

## `data`
1. オプション`end_stream`を`flags`に格納
2. DATAフレームの送信 `send(type: :data, flags: flags, payload: payload)`
    - `payload.bytesize > max_size`の場合はデータをチャンク化する
