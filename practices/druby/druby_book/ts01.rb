# 参照: dRubyによる分散・Webプログラミング
require 'rinda/tuplespace'
require 'drb/drb'

$ts = Rinda::TupleSpace.new # タプルスペースを生成
DRb.start_service('druby://localhost:12345', $ts)
puts DRb.uri
DRb.thread.join

# $ ruby ts01.rb
# druby://localhost:12345

# $ irb --prompt simple -r drb/drb
# >> DRb.start_service
# >> $ts = DRbObject.new_with_uri('druby://localhost:12345')
# => #<DRb::DRbObject:0x00007ff0e0069f40 @ref=nil, @uri="druby://localhost:12345">
# >> $ts.write(['take-test', 1])
# => #<DRb::DRbObject:0x00007ff0e49d8870 @ref=80, @uri="druby://localhost:12345">
# >> $ts.take(['take-test', nil])
# => ["take-test", 1]
# >> $ts.take(['take-test', nil]) タプルがないためブロックする
# => ["take-test", 2] タプルスペースにタプルが置かれるとブロックが解除される

# >> $ts = DRbObject.new_with_uri('druby://localhost:12345')
# => #<DRb::DRbObject:0x00007f9e8b236078 @ref=nil, @uri="druby://localhost:12345">
# >> $ts.write(['take-test', 2])
# => #<DRb::DRbObject:0x00007f9e8b171980 @ref=100, @uri="druby://localhost:12345">
