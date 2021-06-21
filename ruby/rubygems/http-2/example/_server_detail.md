# example/server.rb
- [`http-2/lib/http/2/example/server.rb`](https://github.com/igrigorik/http-2/blob/master/lib/http/2/example/server.rb)

## 9. `conn << data`以降の動作: SETTINGSフレームの送信
- `Connection#receive(frame)`
```ruby
def receive(data)
  @recv_buffer << data
  #...
  @state = :waiting_connection_preface
  payload = @local_settings.reject { |k, v| v == SPEC_DEFAULT_CONNECTION_SETTINGS[k] }
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
end
```

- `Connection#send(type: :settings, stream: 0, payload: payload)`
```ruby
# frame = {:type=>:settings, :stream=>0, :payload=>[[:settings_max_concurrent_streams, 100]], :flags=>[], :length=>6}

def send(frame)
  emit(:frame_sent, frame)
  # :frame_sentイベント: puts "Sent frame: #{frame.inspect}"
  # Sent frame: {:type=>:settings, :stream=>0, :payload=>[[:settings_max_concurrent_streams, 100]]}

  # ...
  frames = encode(frame)
  frames.each { |f| emit(:frame, f) }
  # :frameイベント: sock.is_a?(TCPSocket) ? sock.sendmsg(bytes) : sock.write(bytes)
```
- SETTINGSフレームを送信した後に実際の受信処理を開始している

## 9. `conn << data`以降の動作: SETTINGSフレームを使用したACKの送信
- `Connection#receive(frame)`(続き)
```ruby
def receive(data)
  # ...
  while (frame = @framer.parse(@recv_buffer))
    emit(:frame_received, frame)
    # :frame_received`イベント: puts "Received frame: #{frame.inspect}"
    # Received frame: {:length=>6, :type=>:settings, :flags=>[], :stream=>0, :payload=>[[:settings_max_concurrent_streams, 100]]}

    # ...
    if connection_frame?(frame)
      connection_management(frame)
```

- `Connection#connection_management(frame)`
```ruby
def connection_management(frame)
  # ...
  connection_settings(frame)
```

- `Connection#connection_settings(frame)`
```ruby
def connection_settings(frame)
  # ...
  # @remote_settings[:settings_max_concurrent_streams] = 100
  # ...
  send(type: :settings, stream: 0, payload: [], flags: [:ack])
```

- `Connection#send(frame)`
```ruby
def send(frame)
  emit(:frame_sent, frame)
  # :frame_sentイベント: puts "Sent frame: #{frame.inspect}"
  # Sent frame: {:type=>:settings, :stream=>0, :payload=>[], :flags=>[:ack]}

  # ...
  frames = encode(frame)
  frames.each { |f| emit(:frame, f) } # 逐次実行になっている?
  # :frameイベント: sock.is_a?(TCPSocket) ? sock.sendmsg(bytes) : sock.write(bytes)
end
```

## 9. `conn << data`以降の動作: HEADERSフレームの受信
- `Connection#receive`
```ruby
def receive
  # ...
  while (frame = @framer.parse(@recv_buffer))
    emit(:frame_received, frame)
    # ...
    decode_headers(frame)
    return if @state == :closed
```

- `Connection#decode_headers(frame)`
```ruby
# frame = {:length=>20, :type=>:headers, :flags=>[:end_stream, :end_headers], :stream=>1, :payload=>"\x87\x82A\x8A\xA0\xE4\x1D\x13\x9D\t\xB8\xF0\x1E\a\x84S\x03*/*"}
# @decompressor = #<HTTP2::Header::Decompressor:0x00007fb7c48bd908 @cc=#<HTTP2::Header::EncodingContext:0x00007fb7c48bd840 @table=[], @options={:huffman=>:shorter, :index=>:all, :table_size=>4096}, @limit=4096>>

def decode_headers(frame)
  # ...
  frame[:payload] = @decompressor.decode(frame[:payload])
```

- `Connection#receive`(続き)
```ruby
def receive
  # ...
  # whileの中
  stream = @streams[frame[:stream]]
  if stream.nil? # => true
    stream = activate_stream(
      id:         frame[:stream],
      weight:     frame[:weight] || DEFAULT_WEIGHT,
      dependency: frame[:dependency] || 0,
      exclusive:  frame[:exclusive] || false,
    )
    emit(:stream, stream)
    # :streamイベント: Streamインスタンスに関する様々なイベントの登録
  end

  stream << frame
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

  stream.on(:promise, &method(:promise)) if self.is_a? Server
  # :promiseイベント発信時、Connection#promiseを呼ぶ
  stream.on(:frame,   &method(:send))
  # :frameイベント発信時、Connection#sendを呼ぶ

  @streams[id] = stream
end
```

- `Stream#receive(frame)`
```ruby
def receive(frame)
  transition(frame, false)
  # ...

  emit(:headers, frame[:payload]) unless frame[:ignore]
  # :headersイベント: req = Hash[*h.flatten]; log.info "request headers: #{h}"
  # [Stream 1]: request headers: [[":scheme", "https"], [":method", "GET"], [":authority", "localhost:8080"], [":path", "/"], ["accept", "*/*"]]

  # ...
  complete_transition(frame)
```

- `Stream#transition(frame, false)`
```ruby
def transition(frame, sending)
  # ...
  event(:half_closed_remote)
```

- `Stream#event(:half_closed_remote)`
```ruby
def event(newstate)
  # ...
  @closed = newstate # :half_closed_remote
  emit(:active) unless @state == :open
  # :activeイベント: log.info 'client opened new stream'
  # [Stream 1]: client opened new stream
  @state = :half_closing
```

- `Stream#complete_transition(frame)`
```ruby
def complete_transition(frame)
  # ...
  @state = @closed
  emit(:half_close)
  # :half_closeイベント:
  #   log.info 'client closed its end of the stream'
  #
  #   response = nil
  #   ...
  #   log.info 'Received GET request' => [Stream 1]: Received GET request
  #   response = 'Hello HTTP 2.0! GET request'
  #   ...
  #
  #   stream.headers({
  #     ':status' => '200',
  #     'content-length' => response.bytesize.to_s,
  #     'content-type' => 'text/plain',
  #   }, end_stream: false)
  #   ...
  #   stream.data(response.slice!(0, 5), end_stream: false)
  #   stream.data(response)
```

- `Stream#data(response.slice!(0, 5), end_stream: false)`("Hello")
```ruby
def data(payload, end_stream: true)
  # ...
  max_size = @connection.remote_settings[:settings_max_frame_size]
  # ...
  flags = []
  flags << :end_stream if end_stream
  send(type: :data, flags: flags, payload: payload)
```

- `Stream#send(type: :data, flags: flags, payload: payload))`
```ruby
def send(frame)
  # ...
  send_data(frame)
```

- `FlowBuffer#send_data(frame)`
```ruby
# frame = {:type=>:data, :flags=>[], :payload=>"Hello"}

def send_data(frame = nil, encode = false)
  @send_buffer.push frame unless frame.nil?
  # ...
  while @remote_window > 0 && !@send_buffer.empty?
    frame = @send_buffer.shift

    sent, frame_size = 0, frame[:payload].bytesize

    if frame_size > @remote_window
      payload = frame.delete(:payload)
      chunk   = frame.dup

      # Split frame so that it fits in the window
      # TODO: consider padding!
      frame[:payload] = payload.slice!(0, @remote_window)
      chunk[:length]  = payload.bytesize
      chunk[:payload] = payload

      # if no longer last frame in sequence...
      frame[:flags] -= [:end_stream] if frame[:flags].include? :end_stream

      @send_buffer.unshift chunk
      sent = @remote_window
    else
      sent = frame_size
    end

    manage_state(frame) do
      frames = encode ? encode(frame) : [frame]
      frames.each { |f| emit(:frame, f) }
      @remote_window -= sent
    end
  end
end
```

```ruby
def manage_state(frame)
  transition(frame, true) # 何もしない
  frame[:stream] ||= @id
  yield
  # frameイベント: sock.is_a?(TCPSocket) ? sock.sendmsg(bytes) : sock.write(bytes)
  complete_transition(frame) # 何もしない
end
```

- `Stream#data(response)`(" HTTP 2.0! GET request")
  - `Stream#send(type: :data, flags: flags, payload: payload)`
    - `FlowBuffer#send_data(frame)`
