# Q10 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

EUROPEAN = [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31, 9, 22, 18, 29, 7, 28, 12, 35, 3, 26]
AMERICAN = [0, 28, 9, 26, 30, 11, 7, 20, 32, 17, 5, 22, 34, 15, 3, 24, 36, 13, 1, 00, 27, 10, 25, 29, 12, 8, 19, 31, 18, 6, 21, 33, 16, 4, 23, 35, 14, 2]

def sum_max(rourette, n)
  answer = 0

  rourette.rotate(n).each_cons(n) do |list|
    answer = [answer, list.sum].max
  end

  answer
end

count = (2..36).select { |i| sum_max(EUROPEAN, i) < sum_max(AMERICAN, i) }.count

p count
