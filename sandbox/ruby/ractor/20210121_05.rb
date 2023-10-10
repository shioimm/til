# refs: Ractor#send(obj, move: true) および Ractor.yield(obj, move: true) は、objが共有不可能オブジェクトであれば、move する
# https://github.com/ko1/ruby/blob/ractor/ractor.ja.md#move-%E3%81%AB%E3%82%88%E3%82%8B%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E3%81%AE%E8%BB%A2%E9%80%81

r = Ractor.new do
  obj = Ractor.recv
  p obj.class # => String
  obj << ' World'
end

str = 'Hello'

r.send(str, move: true) # rへ文字列Helloを送信する(move)
pr.take                 # rから返り値を取り出す => "Hello World"

begin
  str << ' Exception'            # rへmoveした文字列を操作しようとしている
rescue Ractor::MovedError
  p 'rescue Ractor::MovedError'  # => rescue Ractor::MovedError
else
  raise                          # Ractor::MovedErrorで捕捉されるためここまでは到達しない
end
