# プログラミングElixir 7.5 ListsAndRecursion-2

defmodule MyList do
  def max([head | [t_head | t_tail]])
  when head > t_head do
    max [head | t_tail]
  end

  def max([head | [t_head | t_tail]])
  when head < t_head do
    max [t_head | t_tail]
  end

  def max([n]) do
    n
  end
end

IO.inspect MyList.max [5, 1, 4, 2, 3]
