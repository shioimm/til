# close_incoming された Ractor に Ractor#sendすると例外。incoming queue が空のとき（ブロックしようとするとき） Ractor.recv すると例外
# https://github.com/ko1/ruby/blob/ractor/ractor.ja.md#ractor-%E3%81%AE-port-%E3%82%92-close

r = Ractor.new do
 'finish'
end

p r.take # rのincoming portがcloseされる

begin
  r.send(1)
rescue Ractor::ClosedError
  p 'OK'
else
  p "NG" # Ractor::ClosedErrorで捕捉されるためここまでは到達しない
end

# => "finish"
# => "OK"
