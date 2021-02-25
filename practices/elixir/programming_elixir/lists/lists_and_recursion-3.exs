# プログラミングElixir 7.5 ListsAndRecursion-3

defmodule MyList do
  def ceasar([s], n)
  when s + n > 26 do
    s + n - 26
  end

  def ceasar([s], n)
  when s + n <= 26 do
    s + n
  end

  def ceasar([ head | tail ], n) do
    [ ceasar([ head ], n) | ceasar(tail, n) ]
  end
end

IO.inspect MyList.ceasar 'abcd', 2
IO.inspect MyList.ceasar 'ryvkve', 13
