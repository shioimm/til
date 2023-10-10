# プログラミングElixir 7.5 ListsAndRecursion-3

defmodule MyList do
  def ceasar([s], n)
  when s + n > 27 do
    [s + n - 27]
  end

  def ceasar([s], n)
  when s + n <= 27 do
    [s + n]
  end

  def ceasar([ head | tail ], n) do
    [ ceasar([ head ], n) | ceasar(tail, n) ]
  end
end

IO.puts MyList.ceasar 'abcd', 2
IO.puts MyList.ceasar 'ryvkve', 13
