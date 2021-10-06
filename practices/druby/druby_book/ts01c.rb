# 参照: dRubyによる分散・Webプログラミング

# $ irb --prompt simple -r drb/drb
# >> DRb.start_service
# >> $ts = DRbObject.new_with_uri('druby://localhost:12345')
# >> tmp, m, n = $ts.take(['fact', Integer, Integer])
# => ["fact", 1, 5]
# >> value = (m..n).inject(1) { |a, b| a * b }
# => 120
# >> $ts.write(['fact-answer', m, n, value])
# => #<DRb::DRbObject:0x00007f9e8b1abfb8 @ref=220, @uri="druby://localhost:12345">
