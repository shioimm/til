# Emitter
- [`http-2/lib/http/2/emitter.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/emitter.rb)
- Connection、Streamでインクルード

#### `#on(= #add_listener)`
- 指定のイベントを購読
  - イベント名と処理を受け取って配列`listeners`に登録する

#### `#once`
- 指定のイベントを一回だけ購読
  - 内部で`#add_listener`を呼ぶ

#### `#emit`
- 指定のイベントをコール
- イベントコール時に`:delete`が返ってきた場合はイベントを削除(#`once`)
