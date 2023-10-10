# refs: 複数の Ractor が一つの Ractor に送信可能
# https://github.com/ko1/ruby/blob/ractor/ractor.ja.md#ractor-%E9%96%93%E3%81%AE%E9%80%81%E5%8F%97%E4%BF%A1

# pipeの生成 A
pipe = Ractor.new do
  loop do
    msg = Ractor.recv # 
    Ractor.yield msg
  end
end

RN = 10

# Ractorの生成 B
rs = RN.times.map do |i|
  Ractor.new(pipe, i) do |pipe, i| # pipeとiを各Ractorに渡す
    pipe.send i                    # pipeに対してiを送信
  end
end

# main C
msgs = RN.times.map do
  pipe.take
end.sort

p msgs # => [0, 1, 2, 3, 4, 7, 5, 6, 8, 9]

# pipeの生成 A
# -> pipeにmsgを送信 B
# -> pipeからmsgを取り出す C
