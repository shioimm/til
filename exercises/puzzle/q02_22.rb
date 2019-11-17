# Q22 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

N = 16
pair = Array.new(N / 2 + 1)
pair[0] = 1

# 8組のペアで試行
1.upto(N / 2) do |i|
  pair[i] = 0
  i.times { |ii| pair[i] += (pair[ii]) * (pair[i - ii - 1]) }
end

p pair[N / 2]
