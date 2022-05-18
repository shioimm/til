# ruby/lib/drb/drb.rb
## サーバー
- `class DRbObject`
  - `#start_service(uri=nil, front=nil, config=nil)`: L1762
    - `@primary_server = DRbServer.new(uri, front, config)`
- `class DRbServer`
  - `#initialize(uri=nil, front=nil, config_or_acl=nil)`: L1450
    - `@protocol = DRbProtocol.open_server(uri, @config)`
    - `@thread = run`
    - `DRb.regist_server(self)`
  - `#run`: L1554
    - `main_loop`
  - `#main_loop`: L1710
    - `client0 = @protocol.accept`
    - `invoke_method = InvokeMethod.new(self, client)`
    - `succ, result = invoke_method.perform`
    - `client.send_reply(succ, result)`
- (`DRbServer#initialize` ->) `module DRbProtocol`
  - `.#open_server(uri, config, first=true)`: L763
    - `prot = DRb::DRbTCPSocket`
    - `prot.open_server(uri, config)`
- `class DRbTCPSocket`
  - `.open_server(uri, config)`: L875
    - `soc = TCPServer.open(host, port)`
    - `self.new(uri, soc, config)`
- (`DRbServer#main_loop` ->) `class InvokeMethod`
  - `#initialize(drb_server, client)`: L1623
  - `#perform`: L1629
    - `#setup_message`: L1632
    - `#init_with_client`: L1655
      - `@client = <DRbTCPSocket>`
      - `@client.recv_request`
    - `#perform_without_block`: L1672
      - `@obj = <Foo>`
      - `@msg_id = :greeting`
      - `@argv = "dRuby"`
      - `@obj.__send__(@msg_id, *@argv)`
- `class DRbTCPSocket`
  - `recv_request(stream)`: L618
    - `ref = load(stream)`
    - `ro = DRb.to_obj(ref)`
    - `msg = load(stream)`
    - `argc = load(stream)`
    - `argv[n] = load(stream)`
    - `block = load(stream)`
    - `return ro, msg, argv, block` (`InvokeMethod#perform_without_block`で使用する)
- (`DRbServer#main_loop` ->) `class DRbTCPSocket`
  - `#send_reply(succ, result)`: L935
    - `@msg = <DRbMessage @load_limit=4294967295, @argc_limit=256>`
    - `stream = <TCPSocket>`
    - `succ = true`
    - `result = "Hello dRuby"`
    - `@msg.send_reply(stream, succ, result)`
- `class DRbMessage`
  - `#send_reply(stream, succ, result)`: L632
    - `dump(succ) = "\x00\x00\x00\x03\x04\bT"`
    - `dump(result, !succ) = "\x00\x00\x00\x15\x04\bI\"\x10Hello dRuby\x06:\x06ET"`
    - `stream.write(dump(succ) + dump(result, !succ))`
  - `#dump(obj, error=false)`: L561
    - `obj = "Hello dRuby"`
    - `obj = make_proxy(obj, error)`
    - `str = Marshal::dump(obj)`
    - `[str.size].pack('N') + str`
      - `str.size = 3`
      - `str = "\x04\bT"`
      - `[str.size].pack('N') + str = "\x00\x00\x00\x03\x04\bT"`
      - `str.size = 21`
      - `str = "\x04\bI\"\x10Hello dRuby\x06:\x06ET"`
      - `[str.size].pack('N') + str = "\x00\x00\x00\x15\x04\bI\"\x10Hello dRuby\x06:\x06ET"`
  - `make_proxy(obj, error=false)`
    - `DRbObject.new(obj)`
- (`DRbServer#initialize` ->) `module DRb`
  - `.#regist_server(server)`: L1906
    - `server = <DRbServer>`
    - `@server[server.uri] = server`
    - `@primary_server = server`

## クライアント
- `class DRbObject`
  - `#method_missing(msg_id, *a, &b)`: L1135
    - `conn.send_message(self, msg_id, a, b)` (DRbObjectオブジェクト、メソッド名、引数[]、&ブロック)
- `class DRbConn`
  - `#send_message(ref, msg_id, arg, block)`: L1322
    - `@protocol = <DRb::DRbTCPSocket>`
    - `@protocol.send_request(ref, msg_id, arg, block)`
    - `@protocol.recv_reply`
- `class DRbTCPSocket` (`@protocol.send_request`)
  - `#send_request(stream, ref, msg_id, arg, b)`: L926
    - `@msg = <DRbMessage>`
    - `@msg.send_request(stream, ref, msg_id, arg, b)`
- `class DRbMessage`
  - `#send_request(stream, ref, msg_id, arg, b)`: L604
    - `stream = <TCPSocket>`
    - `stream.write([ref.__drbref, msg_id.id2name, arg.length, args, b].join(''))`
- `class DRbTCPSocket` (`@protocol.recv_reply`)
  - `#recv_reply(stream)`: L638
    - `[succ, result]`
    - `#load(soc)`: L578
      - `sz = soc.read(4)`
      - `str = soc.read(sz)`
      - `Marshal::load(str)`

## パケット構造
- パケットの長さ (4バイト)
- Marshal文字列
  - `\x04\b` (2バイト)
  - Marshal文字列 (可変長バイト)

#### リクエストパケット
- `ref.__drbref`
- `msg_id.id2name`
- `arg.length`
- `args`
- `b`

```
# #greeting("dRuby")

\x00\x00\x00\x03 | \x04\b  0                         #  3, 0
\x00\x00\x00\x12 | \x04\b  I\"\rgreeting\x06:\x06EF  # 18, "greeting"
\x00\x00\x00\x04 | \x04\b  i\x06                     #  4, 6
\x00\x00\x00\x0F | \x04\b  I\"\ndRuby\x06:\x06ET     # 14, "dRuby"
\x00\x00\x00\x03 | \x04\b  0                         #  3, 0
```

#### レスポンスパケット
- succ
- result

```
\x00\x00\x00\x03 | \x04\b T # => 3, true
\x00\x00\x00\x15 | \x04\b I\"\x10Hello dRuby\x06:\x06ET # => 21, "Hello dRuby"
```

## 参照
- [ruby/lib/drb/drb.rb](https://github.com/ruby/ruby/blob/master/lib/drb/drb.rb)
