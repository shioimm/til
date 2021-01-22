# refs: pipeline with yield/take
# https://github.com/ruby/ruby/blob/master/doc/ractor.md#pipeline

r1 = Ractor.new do
  # 'r1'をメッセージとして送信
  'r1'
end

r2 = Ractor.new(r1) do |r1|
  # 'r1r2'をメッセージとして送信
  r1.take + 'r2'
end

r3 = Ractor.new(r2) do |r2|
  # 'r1r2r3'をメッセージとして送信
  r2.take + 'r3'
end

p r3.take # => 'r1r2r3'
