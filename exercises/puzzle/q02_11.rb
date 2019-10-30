# Q11 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問
arr = []

fib = Enumerator.new do |y|
  a = b = 1
  loop do
    y << a
    divisor = a.to_s.chars.map(&:to_i).sum
    arr << a if a.modulo(divisor).zero?
    a, b = b, a + b

    return p arr if arr.size >= 13
  end
end

p fib.take(100_000_000)
