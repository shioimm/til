# refs: ring example with an error
# https://github.com/ruby/ruby/blob/master/doc/ractor.md#supervise

RN = 3

# main Ractor
r = Ractor.current

# 3個分のRactorの配列
rs = (1..RN).map do |i|
  # r = 最初はmain Ractor、2回目以降は直前に作ったRactor
  # 各Ractorにrとiを渡す
  r = Ractor.new(r, i) do |r, i|
    loop do
      # msgを受信
      # 配列の最後のRactorは'r0'、それよりも前に作ったRactorは'r0' + 'rn...'
      msg = Ractor.recv

      # msgに特定の文字が入っている場合は例外を送出
      raise if msg.match? /e/

      # 直前に作ったRactorへmsg + "r#{i}"を送信
      r.send msg + "r#{i}"
    end
  end
end

# main Ractorから配列の最後のRactorへ'r0'を送信
r.send 'r0'

# 各Ractorから送信されたメッセージをmain Ractorが受信
p Ractor.recv # => "r0r3r2r1"

# main Ractorから配列の最後のRactorへ'r0'を送信
r.send 'r0'

p Ractor.select(*rs, Ractor.current) # => [:receive, "r0r3r2r1"]

# main Ractorから配列の最後のRactorへ'e0'を送信
r.send 'e0'

p Ractor.select(*rs, Ractor.current) # => #<Thread:0x00007fb3111a2298 run> terminated with exception (report_on_exception is true)
