# 参照: dRubyによる分散・Webプログラミング
class Counter
  def initialize
    @value = 0
  end
  attr_reader :value

  def up
    @value += 1
  end
end

def test
  c = Counter.new
  t1 = Thread.new(c) { 10000.times { c.up } }
  t2 = Thread.new(c) { 10000.times { c.up } }

  t1.join
  t2.join

  c.value
end

p test
