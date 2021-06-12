# Emitter
- [http-2/lib/http/2/emitter.rb](https://github.com/igrigorik/http-2/blob/master/lib/http/2/emitter.rb)
- Connection、Streamでインクルード

#### `Emitter#on(= #add_listener)`
- 指定のイベントを購読
  - イベント名と処理を受け取って配列`listeners`に登録する

#### `Emitter#once`
- 指定のイベントを一回だけ購読
  - 内部で`#add_listener`を呼ぶ
