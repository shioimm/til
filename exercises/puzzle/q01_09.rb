# Q09 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

men, women = 20 + 1, 10 + 1
arr = Array.new(women)

women.times do |w|
  arr[w] = Array.new(men)
  men.times { |m| arr[w][m] = 0 }
end

arr[0][0] = 1

women.times do |w|
  men.times do |m|
    if (w != m) && (men - m != women - w)
      arr[w][m] += arr[w][m - 1] if m.positive?
      arr[w][m] += arr[w - 1][m] if w.positive?
    end
  end
end

p arr
pp arr[women - 2][men - 1] + arr[women - 1][men - 2]
