# refs: Ractor#send(obj, move: true) および Ractor.yield(obj, move: true) は、objが共有不可能オブジェクトであれば、move する
# https://github.com/ko1/ruby/blob/ractor/ractor.ja.md#move-%E3%81%AB%E3%82%88%E3%82%8B%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E3%81%AE%E8%BB%A2%E9%80%81

r = Ractor.new do
  obj = 'Hello'
  Ractor.yield(obj, move: true) # ここでmain Ractorに送信される
  obj << ' World'               # move済みのobjを操作しているためRactor::MovedErrorが発生
end

p str = r.take # => "Hello"

begin
  r.take                           # 二回めのtakeでRactor::RemoteErrorが発生
rescue Ractor::RemoteError
  p "Ractor::RemoteError - #{str}" # => Ractor::RemoteError - Hello
else
  raise                            # Ractor::MovedErrorで捕捉されるためここまでは到達しない
end
