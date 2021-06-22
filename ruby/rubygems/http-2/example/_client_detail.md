# example/client.rb
- [`http-2/lib/http/2/example/client.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/example/client.rb)

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
  # emit(:frame, frame) -> Streamの:frameイベント: Connection#send
  complete_transition(frame)
end
```

- `Stream#transition(frame, true)`
```ruby
def transition(frame, sending)
  # ...
  event(:half_closed_local)
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

- `Connection#send`
```ruby
def send(frame)
  emit(:frame_sent, frame)
  # :frame_sentイベント: puts "Sent frame: #{frame.inspect}"
  # ...
  frames = encode(frame)
  frames.each { |f| emit(:frame, f) }
  # Connectionの:frameイベント: ソケットへの書き込み

# Sent frame: {:type=>:headers, :flags=>[:end_headers, :end_stream], :payload=>{":scheme"=>"https", ":method"=>"GET", ":authority"=>"localhost:8080", ":path"=>"/", "accept"=>"*/*"}, :stream=>1}
```

- `Stream#complete_transition(frame)`
```ruby
def complete_transition(frame)
  # ...
  @state = @closed # :half_closed_local
  emit(:half_close)
  # :half_closeイベント: log.info 'closing client-end of the stream'

# [Stream 1]: closing client-end of the stream
```

## 12. `conn << data`以降の動作: SETTINGSフレームの送信
- `Client#send_connection_preface`
```ruby
def send_connection_preface
  return unless @state == :waiting_connection_preface
  @state = :connected
  emit(:frame, CONNECTION_PREFACE_MAGIC)
  # CONNECTION_PREFACE_MAGIC = "PRI * HTTP/2.0\r\n\r\nSM\r\n\r\n".freeze
  # :frameイベント: ソケットへ書き込み

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
```ruby
def send(frame)
  emit(:frame_sent, frame)
  # ...
  frames = encode(frame)
  frames.each { |f| emit(:frame, f) }
  # frameイベント: ソケットへの書き込み
```

- `Connection#receive(data)`
```ruby
def receive(data)
  @recv_buffer << data
  # ...
  while (frame = @framer.parse(@recv_buffer))
    emit(:frame_received, frame)
    # ...
    connection_management(frame)
```

- `Connection#connection_management(frame)`
```ruby
# frame = {:length=>6, :type=>:settings, :flags=>[], :stream=>0, :payload=>[[:settings_max_concurrent_streams, 100]]}

def connection_management
  # ...
  connection_settings(frame)
```

- `Connection#connection_settings(frame)`
```ruby
def connection_settings(frame)
  # ...
  # settings = [[:settings_max_concurrent_streams, 100]]
  # side = :remote
  # @remote_settings = {:settings_header_table_size=>4096, :settings_enable_push=>1, :settings_max_concurrent_streams=>100, :settings_initial_window_size=>65535, :settings_max_frame_size=>16384, :settings_max_header_list_size=>2147483647}

  send(type: :settings, stream: 0, payload: [], flags: [:ack])
```

- `Connection#send(frame)`
```ruby
def send(frame)
  emit(:frame_sent, frame)
  # ...
  frames = encode(frame)
  frames.each { |f| emit(:frame, f) }
  # frameイベント: ソケットへの書き込み
```

## 12. `conn << data`以降の動作: HEADERSフレームの受信
- `Connection#receive(data)`
```ruby
def receive(data)
  @recv_buffer << data

  # ...
  while (frame = @framer.parse(@recv_buffer))
    emit(:frame_received, frame)
    # ...
    decode_headers(frame)
    # ...
    stream = @streams[frame[:stream]]
    # ...
    stream << frame
```

- `Stream#receive(frame)`
```ruby
# frame = {:length=>14, :type=>:headers, :flags=>[:end_headers], :stream=>1, :payload=>[[":status", "200"], ["content-length", "27"], ["content-type", "text/plain"]]}

def receive(frame)
  transition(frame, false) # => なにもしない
  # ...
  emit(:headers, frame[:payload]) unless frame[:ignore]
  # headersイベント: log.info "response headers: #{h}"
  # [Stream 1]: response headers: [[":status", "200"], ["content-length", "27"], ["content-type", "text/plain"]]

  # ...
  complete_transition(frame) # => なにもしない
```

## 12. `conn << data`以降の動作: DATAフレームの送信
- `Connection#receive(data)`
```ruby
def receive(data)
  @recv_buffer << data

  # ...
  while (frame = @framer.parse(@recv_buffer))
    emit(:frame_received, frame)

    # ...
    if (stream = @streams[frame[:stream]])
      stream << frame
```

- `Stream#receive(frame)`
```ruby
# 1回目: frame = {:length=>5, :type=>:data, :flags=>[], :stream=>1, :payload=>"Hello"}
# 2回目: frame = {:length=>22, :type=>:data, :flags=>[:end_stream], :stream=>1, :payload=>" HTTP 2.0! GET request"}

def receive(frame)
  transition(frame, false)
```

- `Stream#transition`
```ruby
def transition
  # ...
  # => 2回目(:end_streamの場合)のみ
  event(:remote_closed)
```

- `Stream#event(:remote_closed)`
```ruby
# 2回目

def event(newstate)
  # ...
  @closed = newstate # => :remote_closed
  @state  = :closing

  # ...
  @state
```

- `Stream#receive(frame)`(続き)
```ruby
# 1回目: frame = {:length=>5, :type=>:data, :flags=>[], :stream=>1, :payload=>"Hello"}
# 2回目: frame = {:length=>22, :type=>:data, :flags=>[:end_stream], :stream=>1, :payload=>" HTTP 2.0! GET request"}

def receive(frame)
  # ...
  update_local_window(frame)
  # ...
  emit(:data, frame[:payload]) unless frame[:ignore]
  # dataイベント: log.info "response data chunk: <<#{d}>>"
  # 1回目: [Stream 1]: response data chunk: <<Hello>>
  # 2回目: [Stream 1]: response data chunk: << HTTP 2.0! GET request>>

  calculate_window_update(@local_window_max_size)
```

- `FlowBuffer#update_local_window(frame)`
```ruby
def update_local_window(frame)
  frame_size = frame[:payload].bytesize
  frame_size += frame[:padding] || 0
  @local_window -= frame_size
end
```

- `FlowBuffer#calculate_window_update(@local_window_max_size)`
```ruby
def calculate_window_update(window_max_size)
  return unless @local_window <= (window_max_size / 2) # => false
  window_update(window_max_size - @local_window)
```

- `Stream#receive(data)`(続き)
```ruby
def receive(data)
  # ...
  complete_transition(frame)
```

- `Stream#complete_transition(frame)`
```
def complete_transition(frame)
  # ...
  @state = :closed
  emit(:close, frame[:error])
  # closeイベント: log.info 'stream closed'
  # [Stream 1]: stream closed
```
