# プロを目指す人のためのRuby入門［改訂2版］P474

class Point
  def initialize(x, y)
    @x, @y = x, y
  end

  def deconstruct
    [@x, @y]
  end

  def deconstruct_keys(_keys)
    { x: @x, y: @y }
  end
end

case Point.new(10, 20)
in [1, 2] then p '[1, 2] matched'
in [10, 20] then p '[10, 20] matched'
end

case Point.new(10, 20)
in { x: 1, y: 2 } then p '{ x: 1, y: 2 } matched'
in { x: 10, y: 20 } then p '{ x: 10, y: 20 } matched'
end

case Point.new('x', 'y')
in Point(10, 20) then p 'Point(10, 20) matched'
in Point('x', 'y') then p "Point('x', 'y') matched"
end
