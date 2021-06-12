# Connection
- [http-2/lib/http/2/connection.rb](https://github.com/igrigorik/http-2/blob/master/lib/http/2/connection.rb)
- Client、Serverへ継承

#### コネクション中に新しいストリームを生成する
- `Connection#new_stream`
  - `Connection#activate_stream`
  - `@stream_id`の更新
- `Connection#activate_stream`
  - `stream = Stream.new`
  - `stream.once` - `:active` / `:close`イベントの購読
  - `stream.on` - `:promise` / `:frame`イベントの購読
