# Q17 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

N = 30

boy, girl = 1, 0

N.times do |i|
  boy, girl = boy + girl, boy
end

puts boy + girl
