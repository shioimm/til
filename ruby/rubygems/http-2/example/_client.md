# example/client.rb
- [`http-2/lib/http/2/example/client.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/example/client.rb)

## 動作フロー
1. オプションパース
    - `:payload`オプション
2. TLSを利用したプロトコルアップグレード・暗号化接続ソケット(`OpenSSL::SSL::SSLSocket`)の生成
    - リクエストURIスキームがHTTPSではない場合: 接続ソケット(`TCPSocket`)の生成
3. コネクションの作成
    - `HTTP2::Client`インスタンスを生成
      - `@stream_id = 1`
      - `@state = :waiting_connection_preface`
      - `@local_role = :client`
      - `@remote_role = :server`
4. ストリームの作成
    - `HTTP2::Client`インスタンスからアクティブな`HTTP2::Stream`インスタンスを生成
5. ロガーの生成
6. コネクションによるイベントの購読を登録
    - `:frame(frame)`
    - `:frame_sent(frame)`
    - `:frame_received(frame)`
    - `:promise(stream)`
      - ストリームによるイベントの購読を登録
        - `:promise_headers(frame[:payload])`
        - `:headers(frame[:payload])`
        - `:data(frame[:payload])`
    - `:altsvc` - デフォルトでは発信されていない
7. ストリームによるイベントの購読を登録
    - `:close(frame[:error])`
    - `:half_close(引数なし)`
    - `:headers(frame[:payload])`
    - `:data(frame[:payload])`
    - `:altsvc` - デフォルトでは発信されていない
8. リクエストヘッダの設定
9. GETの場合 - HEADERフレームの送信 / POSTの場合 - HEADERフレーム・DATAフレームの送信
10. ループ処理の開始(ソケットがEOFに至るまで、またはクローズするまで)
11. レスポンスのうち1024バイトをノンブロッキングで読み込み
12. [begin]コネクションによる受信処理(`Client#receive(frame)`)
    - 読み込んだデータ(`@recv_buffer`)から9バイトずつフレームを読み出す
    - フレームタイプ別の処理
13. [rescue]ソケットの切断

## 4. `stream = conn.new_stream`以降の動作
- `Connection#new_stream`
```ruby
def new_stream(**args)
  # ...
  stream = activate_stream(id: @stream_id, **args)
  @stream_id += 2 # 奇数はクライアント・偶数はサーバー

  stream
end
```

- `Connection#activate_stream`
```ruby
def activate_stream(id: nil, **args)
  # ...
  stream = Stream.new(**{ connection: self, id: id }.merge(args))
  # ...
  stream.once(:active) { @active_stream_count += 1 }
  stream.once(:close) do
    @active_stream_count -= 1
    # ...
    @streams_recently_closed[id] = Time.now.to_i
    cleanup_recently_closed
  end

  # ...
  stream.on(:frame,   &method(:send)) # Streamの:frameイベント時にConnection#sendが呼ばれる

  @streams[id] = stream
end
```

## 9. `stream.headers(head, end_stream: true)`以降の動作
- `Stream#headers(head, end_headers: true)`

```ruby
def headers(headers, end_headers: true, end_stream: false)
  flags = []
  flags << :end_headers if end_headers
  flags << :end_stream  if end_stream

  send(type: :headers, flags: flags, payload: headers)
end
```

- `Stream#send(type: :headers, flags: flags, payload: headers)`
```ruby
def send(frame)
  # ...
  manage_state(frame) do
    emit(:frame, frame)
  end
end
```

- `Stream#manage_state(frame)`
```ruby
def manage_state(frame)
  transition(frame, true)
  frame[:stream] ||= @id
  yield
  # emit(:frame, frame) -> Streamの:frameイベント -> Connection#send
  complete_transition(frame)
end
```

- `Stream#transition(frame, true)`
```ruby
def transition(frame, sending)
  # ...
  event(:half_closed_local)
```

- `Connection#send`
```ruby
def send(frame)
  emit(:frame_sent, frame)
  # :frame_sentイベント -> puts "Sent frame: #{frame.inspect}"
  # ...
  frames = encode(frame)
  frames.each { |f| emit(:frame, f) }
  # Connectionの:frameイベント -> ソケットへの書き込み

# Sent frame: {:type=>:headers, :flags=>[:end_headers, :end_stream], :payload=>{":scheme"=>"https", ":method"=>"GET", ":authority"=>"localhost:8080", ":path"=>"/", "accept"=>"*/*"}, :stream=>1}
```

- `Stream#event(:half_closed_local)`
```ruby
def event(newstate)
  # ...
  @closed = newstate # @closed = :half_closed_local
  emit(:active) unless @state == :open
  # ...
  @state = :half_closing
```

- `Stream#complete_transition(frame)`
```ruby
def complete_transition(frame)
  # ...
  @state = @closed # :half_closed_local
  emit(:half_close)
  # :half_closeイベント -> log.info 'closing client-end of the stream'

# [Stream 1]: closing client-end of the stream
```

## 12. `conn << data`以降の動作
- `Client#send_connection_preface`
```ruby
def send_connection_preface
  return unless @state == :waiting_connection_preface
  @state = :connected
  emit(:frame, CONNECTION_PREFACE_MAGIC)
  # CONNECTION_PREFACE_MAGIC = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n".freeze
  # :frameイベント -> ソケットへ書き込み

  payload = @local_settings.reject { |k, v| v == SPEC_DEFAULT_CONNECTION_SETTINGS[k] }
  # SPEC_DEFAULT_CONNECTION_SETTINGS: SETTINGSフレームのデフォルト値(Hash)

  settings(payload)
```

- `Connection#settings(payload)`
```ruby
def settings(payload)
  payload = payload.to_a
  connection_error if validate_settings(@local_role, payload)
  @pending_settings << payload
  send(type: :settings, stream: 0, payload: payload)
  @pending_settings << payload
```

- `Connection#send(frame)`
WIP
