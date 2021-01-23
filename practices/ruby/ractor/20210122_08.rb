# refs: ring example with supervisor and re-start
# https://github.com/ruby/ruby/blob/master/doc/ractor.md#supervise

RN = 3

def make_ractor(r, i)
  Ractor.new(r, i) do |r, i|
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

# main Ractor
r = Ractor.current

# 3個分のRactorの配列
rs = (1..RN).map do |i|
  # r = 最初はmain Ractor、2回目以降は直前に作ったRactor
  # 各Ractorにrとiを渡す
  r = make_ractor(r, i)
end

msg = 'e0'

begin
  # main Ractorから配列の最後のRactorへ'e0'を送信
  r.send msg
  p Ractor.select(*rs, Ractor.current)
rescue Ractor::RemoteError
  p 'rescued' # => "rescued"

  # このとき変数r Ractorはすでにincoming-portが閉じているため、
  # retryでsendし直すとRactor::ClosedErrorが発生する
  # 変数rには配列の末尾の要素のRactorが入っているため、
  # 変数r/配列の末尾の要素に新しいRactorを作って代入し直す
  r = rs[-1] = make_ractor(rs[-2], rs.size - 1)

  # 例外が発生しないメッセージ
  msg = 'x0'
  retry # => [:receive, "x0r2r2r1"]
end
