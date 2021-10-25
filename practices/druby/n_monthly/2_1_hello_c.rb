# n月刊ラムダノートVol2No1(2020) dRuby で楽しむ分散オブジェクト
require 'drb'

DRb.start_service
foo = DRbObject.new_with_uri('druby://localhost:54300')
foo.greeting
