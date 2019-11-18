# Q23 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

@memo = {}

def game(coin, depth)
  return @memo[[coin, depth]] if @memo.key? [coin, depth]
  return 0 if coin.eql? 0
  return 1 if depth.eql? 0

  win = game(coin + 1, depth - 1)
  lose = game(coin - 1, depth - 1)
  @memo[[coin, depth]] = win + lose
end

p game(10, 24)
