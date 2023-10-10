# refs: 複数の Ractor が一つの Ractor に対して待ち合わせが可能（Ractor.select）
# https://github.com/ko1/ruby/blob/ractor/ractor.ja.md#ractor-%E9%96%93%E3%81%AE%E9%80%81%E5%8F%97%E4%BF%A1

# pipeの生成 A
pipe = Ractor.new do
  loop do
    msg = Ractor.recv
    Ractor.yield msg
  end
end

RN = 10

# Ractorの生成 B
rs = RN.times.map do |i|
  Ractor.new(pipe, i) do |pipe, i| # pipeとiを各Ractorに渡す
    msg = pipe.take                # pipeが受信し、送信したmsgを取り出す
    msg                            # pipeから取り出したmsgを返す
  end
end

# pipeにmsgを送信 C
RN.times do |i|
  pipe.send i
end

# main D
msgs = RN.times.map do
  r, msg = Ractor.select(*rs) # 準備ができたRactorを待ち受ける
  p r                         # どのRactorインスタンスからメッセージが届いたのか
  rs.delete r                 # deleteしないとRactor::ClosedErrorになる(The outgoing-port is already closed)
  msg
end.sort

p msgs # => [0, 1, 2, 3, 4, 7, 5, 6, 8, 9]

# pipeの生成 A
# -> pipeにmsgを送信 C
# -> pipeからmsgを取り出す B
# -> 対象のRactorに対してselect D
