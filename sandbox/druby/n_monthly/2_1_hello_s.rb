# n月刊ラムダノートVol2No1(2020) dRuby で楽しむ分散オブジェクト
require 'drb'

class Foo
  def greeting
    puts 'Hello, World'
  end
end

foo = Foo.new
DRb.start_service('druby://localhost:54300', foo)
sleep
