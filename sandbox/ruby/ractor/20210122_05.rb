# refs: ring example again
# https://github.com/ruby/ruby/blob/master/doc/ractor.md#supervise

RN = 10

# main Ractor
r = Ractor.current

# 10個分のRactorの配列
rs = (1..RN).map do |i|
  # 各Ractorにmain Ractorとiを渡す
  r = Ractor.new(r, i) do |r, i|
    msg = Ractor.recv + "r#{i}"

    # main Ractorにmsgを送信
    r.send msg
  end
end

# main Ractorからmain Ractor自身へ'r0'を送信
r.send 'r0'

# 各Ractorから送信されたメッセージをmain Ractorで受信
# incoming-portにキューが積まれるまではブロックする
p Ractor.recv # => "r0r10r9r8r7r6r5r4r3r2r1"
