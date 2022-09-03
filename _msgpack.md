# MessagePack
- JSONデータをバイナリにシリアライズし保存する汎用フォーマット
- fluentdがデータ通信をする際のフォーマットとして利用されている

```ruby
require "msgpack"

# シリアライズ (1)
obj = { "key1": 1, "key2": "2", "key3" [1, 2, 3] }
msg = MessagePack.pack(obj) # obj.to_msgpack
File.binwrite('data.msgpack', msg)

# デシリアライズ (1)
msg = File.binread('mydata.msgpack')
obj = MessagePack.unpack(msg)

# シリアライズ (2)
pk = MessagePack::Packer.new(io)
pk.write_array_header(2).write(e1).write(e2).flush

# デシリアライズ (2)
u = MessagePack::Unpacker.new(io)
u.each { |obj| ... }
```

## 参照
- [MessagePack](https://msgpack.org/ja.html)
