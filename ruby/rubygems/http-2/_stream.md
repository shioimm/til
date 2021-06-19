# Stream
- [`http-2/lib/http/2/stream.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/stream.rb)

## `#initialize`
- インスタンス変数の初期化
- 優先度の設定
- `:window` / `:local_window`イベントの購読

## `#receive`
- `Stream#transition`
- フレームタイプ別の処理
- `Stream#complete_transition`

### フレームタイプ

| フレーム         | 処理                                                                                       |
| -                | -                                                                                          |
| `:data`          | `FlowBuffer#update_local_window` -> イベントコール -> `FlowBuffer#calculate_window_update` |
| `:headers`       | イベントコール                                                                             |
| `:push_promise`  | イベントコール                                                                             |
| `:priority`      | `Stream#process_priority`                                                                  |
| `:window_update` | `FlowBuffer#process_window_update`                                                         |
| `:altsvc`        | `if !frame[:origin] || frame[:origin].empty?`の場合イベントコール                          |
| `:blocked`       | イベントコール                                                                             |

## `#send`
- `Stream#process_priority`
- フレームタイプ別の処理

### フレームタイプ

| フレーム          | 処理                   |
| -                 | -                      |
| `:data`           | `FlowBuffer#send_data` |
| `:window_update`  | `Stream#manage_state`  |
| その他            | `Stream#manage_state`  |

## `#manage_state`
- `Stream#transition`
- 与えられたブロックの実行
- `Stream#complete_transition`

## `#transition`
- `@state`の状態別の処理

### `@state`の状態
- `:idle`
- `:reserved_local`
- `:reserved_remote`
- `:open`
- `:half_closed_local`
- `:half_closed_remote`
- `:closed`


## `#complete_transition`
- `@state`の状態別の処理

| フレーム          | 処理                                          |
| -                 | -                                             |
| `:closing`        | `@state`の変更 -> `:close`イベントコール      |
| `:half_closing`   | `@state`の変更 -> `:half_close`イベントコール |

## `#headers`
1. オプション`:end_headers`、`:end_stream`をフラグに格納
2. HEADERフレームの送信 `send(type: :headers, flags: flags, payload: headers)`

## `data`
1. オプション`:end_stream`をフラグに格納
2. DATAフレームの送信 `send(type: :data, flags: flags, payload: payload)`
    - `payload.bytesize > max_size`の場合はデータをチャンク化する
