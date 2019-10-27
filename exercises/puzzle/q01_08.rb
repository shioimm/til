# Q08 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

N = 12

initial_position = [0, 0]

UP    = [1, 0]
DOWN  = [-1, 0]
LEFT  = [0, 1]
RIGHT = [0, -1]

def move(log)
  return 1 if log.size.eql? N + 1

  count = 0
  target_log = log.last

  [UP, DOWN, LEFT, RIGHT].each do |direction|
    next_vertical   = target_log.first + direction.first
    next_horizontal = target_log.last + direction.last
    next_position   = [next_vertical, next_horizontal]

    count += move(log + [next_position]) unless log.include? next_position
  end

  count
end

p move([initial_position])
