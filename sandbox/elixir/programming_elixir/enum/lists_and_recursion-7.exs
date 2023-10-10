# プログラミングElixir 10.4 ListsAndRecursion-7

defmodule MyList do
  def span(from, to)
  when from < to do
    [from | span((from + 1), to)]
  end

  def span(_, to) do
    [to]
  end
end

nums = MyList.span(2, 10)
nums -- for x <- nums, y <- nums, y < x, rem(x, y) == 0, do: x
|> IO.inspect # => [2, 3, 4, 5]
