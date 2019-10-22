# Q01 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

11.step(by: 2) do |n|
  next if n.to_s != n.to_s.reverse
  next if n.to_s(2) != n.to_s(2).reverse
  next if n.to_s(8) != n.to_s(8).reverse

  return p n
end
