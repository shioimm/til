# refs: worker pool
# https://github.com/ruby/ruby/blob/master/doc/ractor.md#worker-pool

require 'prime'

# A
pipe = Ractor.new do
  loop do
    # msgをincoming-portから受け取る
    msg = Ractor.recv

    # msgをoutgoing-portへ送る
    Ractor.yield msg
  end
end

N = 100
RN = 10

# B
# 10個分のワーカーRactorの配列
workers = (1..RN).map do
  # pipe Ractorを各ワーカーに渡す
  Ractor.new(pipe) do |pipe|
    # pipe Ractorから送信されたmsgをtakeする
    # pipe Ractorからmsgが届くまでブロック
    while n = pipe.take
      msg = "#{n} is #{'not ' unless n.prime?}a prime."

      # msgをoutgoing-portへ送る
      Ractor.yield msg
    end
  end
end

# C
(1..N).each do |i|
  # msgをpipe Ractorへ送る
  pipe.send i
end

# D
(1..N).map do
  # 計算が終わったワーカーRactorから取り出して出力
  _, msg = Ractor.select(*workers)

  p msg
end

# A -> C -> B -> D
