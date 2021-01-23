# refs: pipeline with send/recv
# https://github.com/ruby/ruby/blob/master/doc/ractor.md#pipeline

# main Ractor
cr = Ractor.current

r3 = Ractor.new(cr) do |cr|
  # msg = incoming-portから受信したメッセージ'r0r1r2' + 'r3'
  msg = Ractor.recv + 'r3'

  # outgoing-portからmain Ractorにmsgを送信する
  cr.send msg
end

r2 = Ractor.new(r3) do |r3|
  # msg = incoming-portから受信したメッセージ'r0r1' + 'r2'
  msg = Ractor.recv + 'r2'

  # outgoing-portからr3 Ractorにmsgを送信する
  r3.send msg
end

r1 = Ractor.new(r2) do |r2|
  # msg = incoming-portから受信したメッセージ'r0' + 'r1'
  msg = Ractor.recv + 'r1'

  # outgoing-portからr2 Ractorにmsgを送信する
  r2.send msg
end

# r1 Ractorに'r0'を送信する
r1.send 'r0'

# main Ractorでメッセージを受信する
p Ractor.recv # => 'r0r1r2r3'
