# プログラミングElixir 7.5 ListsAndRecursion-1

defmodule MyList do
  def mapsum([], _) do
    0
  end

  def mapsum([ head | tail ], func) do
    func.(head) + mapsum(tail, func)
  end
end

IO.puts MyList.mapsum [1, 2, 3], &(&1 * &1)
