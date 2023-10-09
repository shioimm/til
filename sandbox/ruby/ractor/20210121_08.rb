# refs: 共有可能オブジェクトのインスタンス変数は、main Ractor（最初に生成されたオブジェクト）からのみアクセス可
# https://github.com/ko1/ruby/blob/ractor/ractor.ja.md#%E5%85%B1%E6%9C%89%E4%B8%8D%E5%8F%AF%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E3%82%92%E5%85%B1%E6%9C%89%E3%81%95%E3%81%9B%E3%81%AA%E3%81%84%E3%81%9F%E3%82%81%E3%81%AB

shared = Ractor.new {}
shared.instance_variable_set(:@iv, 'str')

r = Ractor.new(shared) do |shared|
  p shared.instance_variable_get(:@iv)
end

begin
  r.take
rescue => e
  p e               # => #<Ractor::RemoteError: thrown by remote Ractor.>
  p e.cause.message # => "can not access instance variables of shareable objects from non-main Ractors"
end
