# FlowBuffer
- [`http-2/lib/http/2/flow_buffer.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/flow_buffer.rb)
- Connection、Streamでインクルード

## `#send_data`
- 送出されるDATAフレームをバッファリングし、現在の`@remote_window`に基づいて分割送出する
  - `@remote_window`が十分な場合: 即送信
  - `@remote_window`が不十分な場合: フロー制御ウィンドウが更新されるまでデータをバッファリング

## `#process_window_update`
- `@remote_window`をインクリメント
- `FlowBuffer#send_data`
