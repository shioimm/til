# n月刊ラムダノートVol2No1(2020) dRuby で楽しむ分散オブジェクト
require 'drb'

queue = Queue.new
DRb.start_service('druby://localhost:54321', queue)
puts DRb.uri
sleep
