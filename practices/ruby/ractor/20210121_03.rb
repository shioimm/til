# refs: close_outgoing された Ractor で Ractor.yield する、もしくは Ractor#take すると例外
# https://github.com/ko1/ruby/blob/ractor/ractor.ja.md#ractor-%E3%81%AE-port-%E3%82%92-close

r = Ractor.new do
  'finish'
end

p r.take # rのoutgoing portがcloseされる

begin
  r = r.take
rescue Ractor::ClosedError
  p 'OK'
else
  p "NG" # Ractor::ClosedErrorで捕捉されるためここまでは到達しない
end

# => "finish"
# => "OK"
