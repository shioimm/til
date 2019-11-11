# Q15 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

MAXIMUM = 10
STEPS   = 4
@memo   = {}

def move(a, b)
  return @memo[[a, b]]     if @memo.key? [a, b]
  return @memo[[a, b]] = 0 if a > b
  return @memo[[a, b]] = 1 if a.eql? b

  count = 0

  (1..STEPS).each do |a_step|
    (1..STEPS).each do |b_step|
      count += move(a + a_step, b - b_step)
    end
  end

  @memo[[a, b]] = count
end

puts move(0, MAXIMUM)
