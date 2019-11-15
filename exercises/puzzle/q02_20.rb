# Q20 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

square = [1, 14, 14, 4, 11, 7, 6, 9, 8, 10, 10, 5, 13, 2, 3, 15].freeze

sum_all = square.sum

sum = Array.new(sum_all + 1) { 0 }

sum[0] = 1

square.each do |n|
  (sum_all - n).downto(0).each do |nn|
    sum[nn + n] += sum[nn]
  end
end

p sum.index(sum.max)
