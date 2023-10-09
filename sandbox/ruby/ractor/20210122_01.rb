# refs: fork-join
# https://github.com/ruby/ruby/blob/master/doc/ractor.md#fork-join

def fib(n)
  return 1 if n < 2

  fib(n - 2) + fib(n - 1)
end

RN = 10

# フィボナッチ数を非同期に計算する10個分のRactorの配列
rs = (1..RN).map do |i|
  Ractor.new(i) do |i|
    # 元の数: フィボナッチ数
    "#{i}: #{fib(i)}"
  end
end

until rs.empty?
  r, v = Ractor.select(*rs)
  p r

  # take済みのRactorを配列から削除
  # 削除しないと次のselectでRactor::ClosedErrorになる
  rs.delete r

  p v
end
