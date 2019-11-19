# Q24 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

board = [
  [1, 2], [2, 3], [7, 8], [8, 9],
  [1, 4], [3, 6], [4, 7], [6, 9]
]

1.upto(9) { |i| board.push [i] }

@memo = { [] => 1 }

def strike(board)
  return @memo[board] if @memo.key? board

  count = 0

  board.each do |b|
    next_board = board.select { |bb| (b & bb).empty? }
    count += strike(next_board)
  end

  @memo[board] = count
end

puts strike(board)
