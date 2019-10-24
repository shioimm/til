# Q05 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

MAXIMUM_PRICE    = 1000
RANGE_OF_NUMBERS = 2..15
COINS            = [500, 100, 50, 10]

count = 0

RANGE_OF_NUMBERS.each do |number|
  # number枚の重複組み合わせをすべて生成し、
  # その各組み合わせのsumがMAXIMUM_PRICE円になる組み合わせの数を数える
  count += COINS.repeated_combination(number).select { |coins| coins.sum.eql? MAXIMUM_PRICE }.size
end

pp count

# Array#repeated_combination
# https://docs.ruby-lang.org/ja/2.6.0/method/Array/i/repeated_combination.html
