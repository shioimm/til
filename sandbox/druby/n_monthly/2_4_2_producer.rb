# n月刊ラムダノートVol2No1(2020) dRuby で楽しむ分散オブジェクト
require 'drb'

DRb.start_service
queue = DRbObject.new_with_uri('druby://localhost:54321')
puts 'push "Hello, Again."'
queue.push("Hello, Again.")

puts 'push "one"'
queue.push("one")

puts 'push 2'
queue.push(2)

puts 'push 3.0'
queue.push(3.0)
