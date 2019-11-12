# Q15 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

MAXIMUM = 500

count = 0

(1..MAXIMUM / 4).each do |c|
  # 正方形の一辺の最小値~最大値までの全ての組み合わせ
  (1..c - 1).to_a.combination(2) do |a, b|
    # ピタゴラスの定理が成り立つ場合
    count += 1 if (a * a + b * b).eql?(c * c)
  end
end

puts count

# Array#combination
# https://docs.ruby-lang.org/ja/2.6.0/method/Array/i/combination.html
# Integer#gcd
# https://docs.ruby-lang.org/ja/2.6.0/method/Integer/i/gcd.html
