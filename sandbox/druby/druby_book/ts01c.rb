# 参照: dRubyによる分散・Webプログラミング

# $ irb --prompt simple -r drb/drb -r rinda/tuplespace
# >> $ts = Rinda::TupleSpace.new
# >> DRb.start_service('druby://localhost:12345', $ts)
# >> $ts.write(['fact', 1, 5])
# => #<DRb::DRbObject:0x00007ff0e4a22678 @ref=200, @uri="druby://localhost:12345">
# >> res = $ts.take(['fact-answer', 1, 5, nil]) ブロック
# => ["fact-answer", 1, 5, 120] ブロック解除

require 'drb/drb'

def fact_client(ts, a, b)
  ts.write(['fact', a, b])
  tuple = ts.take(['fact-answer', a, b, nil])
  return tuple[3]
end

ts_uri = ARGV.shift || 'druby://localhost:12345'
DRb.start_service
$ts = DRbObject.new_with_uri(ts_uri)
p fact_client($ts, 1, 5)
