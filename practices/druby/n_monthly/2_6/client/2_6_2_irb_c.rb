# n月刊ラムダノートVol2No1(2020) dRuby で楽しむ分散オブジェクト

require 'drb'
require 'irb'

uri = ARGV.shift

DRb.start_service
IRB.setup(eval("__FILE__"), argv: [])
workspace = DRbObject.new_with_uri(uri)
IRB.conf[:INSPECT_MODE] = false
IRB::Irb.new(workspace).run(IRB.conf)

# $ docker build -t test/irb_c .
# $ docker run -it --rm test/irb_c druby://172.17.0.2:54345
# irb(main):001:0> DRb.uri
# => druby://172.17.0.2:54345
# irb(main):002:0> $server
# => #<WEBrick::HTTPServer:0x000055f4da0ac2b8>
# irb(main):003:0> $server.mount_proc('/time') { |req, res| res.body = Time.now.to_s }
# => [#<WEBrick::HTTPServlet::ProcHandler:0x000055f4d9ce7718 @proc=#<Proc:0x000055f4d9ce7740 (irb):3>>, []]
# irb(main):004:0> queue = Queue.new
# => #<Thread::Queue:0x000055f4d9f0f2e8>
# irb(main):005:0> $server.mount_proc('/queue') { |req, res| res.body = queue.pop.inspect }
# => [#<WEBrick::HTTPServlet::ProcHandler:0x000055f4d9fa9988 @proc=#<Proc:0x000055f4d9fa99b0 (irb):5>>, []]

# $ docker run -it --rm rubylang/ruby irb --simple-prompt
# >> require 'drb'
# => true
# >> remote_workspace = DRbObject.new_with_uri('druby://172.17.0.2:54345')
# => #<DRb::DRbObject:0x000055ea9a582ed0 @uri="druby://172.17.0.2:54345", @ref=nil>
# >> queue = remote_workspace.local_variable_get('queue')
# => #<DRb::DRbObject:0x000055ea9a30aef0 @uri="druby://172.17.0.2:54345", @ref=1540>
# >> queue.push("Hello, Again")
# => #<DRb::DRbObject:0x000055ea9a639158 @uri="druby://172.17.0.2:54345", @ref=1540>
