# プログラミングElixir 7.6 ListsAndRecursion-4

defmodule MyList do
  def span(from, to)
  when from < to do
    [from | span((from + 1), to)]
  end

  def span(_, to) do
    [to]
  end
end

IO.inspect MyList.span 1, 3
