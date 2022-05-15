# ruby/lib/drb/drb.rb
## クライアント
- `class DRbObject`
  - `#method_missing(msg_id, *a, &b)`: L1135
    - `conn.send_message(self, msg_id, a, b)` (DRbObjectオブジェクト、メソッド名、引数[]、&ブロック)
- `class DRbConn`
  - `#send_message(ref, msg_id, arg, block)`: L1324
    - `@protocol = <DRb::DRbTCPSocket>`
    - `@protocol.send_request(ref, msg_id, arg, block)`
    - `@protocol.recv_reply`
- `class DRbTCPSocket` (`@protocol.send_request`)
  - `send_request(stream, ref, msg_id, arg, b)`: L926
    - `@msg = <DRbMessage>`
    - `@msg.send_request(stream, ref, msg_id, arg, b)`
- `class DRbMessage`
  - `send_request(stream, ref, msg_id, arg, b)`: L604
    - `stream = <TCPSocket>`
    - `stream.write([ref.__drbref, msg_id.id2name, arg.length, args, b].join(''))`
- `class DRbTCPSocket` (`@protocol.recv_reply`)
  - `recv_reply(stream)`: L638
    - `[succ, result]`
  - `load(soc)`: L578
    - `sz = soc.read(4)`
    - `str = soc.read(sz)`
    - `Marshal::load(str)`

#### 送信パケット
- `ref.__drbref`
- `msg_id.id2name`
- `arg.length`
- `args`
- `b`

```
# #greeting("dRuby")

\x00\x00\x00\x03\x04\b0
\x00\x00\x00\x12\x04\bI\"\rgreeting\x06:\x06EF
\x00\x00\x00\x04\x04\bi\x06
\x00\x00\x00\x0F\x04\bI\"\ndRuby\x06:\x06ET
\x00\x00\x00\x03\x04\b0
```

#### 受信パケット
- `succ` / `result`
  - `soc.read(4)` - 最初の4バイトが受信パケット全体の長さを表している
  - `soc.read(sz)` - `Marshal.load`する対象となる文字列全体

```
# succ
"\x00\x00\x00\x03" # => 3
"\x04\bT"          # => true

# result
"\x00\x00\x00\x15" # => 21
"\x04\bI\"\x10Hello dRuby\x06:\x06ET" # => "Hello dRuby"
```

## 参照
- [ruby/lib/drb/drb.rb](https://github.com/ruby/ruby/blob/master/lib/drb/drb.rb)
