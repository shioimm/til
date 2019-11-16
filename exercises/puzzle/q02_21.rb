# Q21 from プログラマ脳を鍛える数学パズル シンプルで高速なコードが書けるようになる70問

count = 0
line = 1
row = 1

while count < 2014 do
  row = row ^ row << 1
  count += row.to_s(2).count('0')
  line += 1
end

p line

# Integer#<<
# https://docs.ruby-lang.org/ja/2.6.0/method/Integer/i/=3c=3c.html
