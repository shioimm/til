# Q03 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

RANGE = 1..100

RANGE.each do |i|
  flag = false
  RANGE.each { |ii| flag = !flag if i.modulo(ii).zero? }
  p i if flag
end
