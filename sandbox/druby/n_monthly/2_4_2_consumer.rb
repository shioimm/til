# n月刊ラムダノートVol2No1(2020) dRuby で楽しむ分散オブジェクト
require 'drb'

DRb.start_service
queue = DRbObject.new_with_uri('druby://localhost:54321')
puts 'pop'
p queue.pop

sleep 5

puts 'pop'
p queue.pop
puts 'pop'
p queue.pop
puts 'pop'
p queue.pop
puts 'pop'
p queue.pop
