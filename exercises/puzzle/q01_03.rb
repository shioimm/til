# Q03 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

(1..100).each do |i|
  pp i if (1..i).select { |n| (i % n).zero? }.size.odd?
end
