# https://github.com/ko1/ruby/blob/ractor/ractor.ja.md#ractor-%E3%81%AE%E7%94%9F%E6%88%90
# https://github.com/ko1/ruby/blob/ractor/ractor.ja.md#ractor-%E9%96%93%E3%81%AE%E3%82%B3%E3%83%9F%E3%83%A5%E3%83%8B%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3

r1 = Ractor.new(name: 'test') do
  self.object_id
end

puts "r1.name        - #{r1.name}"
puts "r1.take        - #{r1.take}"
puts "r1.object_id   - #{r1.object_id}"
puts "self.object_id - #{self.object_id}"

puts '--------------'

r2 = Ractor.new('ok') do |msg|
  msg
end

puts "r2.take - #{r2.take}"

puts '--------------'

# push型 send -> recv
# sendする側が宛先を知っている
# aka actor model
r3 = Ractor.new do
  msg = Ractor.recv
end

r3.send 'ok'

puts "r3.take - #{r3.take}"

puts '--------------'

# pull型 yield <- take
# takeする側が送信元を知っている
# akaランデブー
r4 = Ractor.new do
  Ractor.yield 'ok'
end

puts "r4.take - #{r4.take}"

puts '--------------'

r5 = Ractor.new do
  raise 'ok'
end

begin
  r5.take
rescue Ractor::RemoteError => e
  puts "r5 e.cause         - #{e.cause.class}"
  puts "r5 e.cause.message - #{e.cause.message}"
  puts "r5 e.ractor        - #{e.ractor}"
end

# -------------------
# Ractor.select - take/recv/yieldのどれかが成功するまで待つ
#
# -------------------
#
# Ractor#close_incoming - incoming portをclose(sendできなくなる)
# Ractor#close_outgoing - outgoing portをclose(take/yieldできなくなる)
# Ractorが終了するとincoming port/outgoing portはcloseされる
#
# ------------------
#
# Ractror間送受信send/yield move: trueオプション
#   - 参照の送信
#   - ディープコピーの送信
#   - 移動(送信後、送信元で用いないことが前提)
# -------------------
