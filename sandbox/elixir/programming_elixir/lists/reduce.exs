# プログラミングElixir 7.5 lists/reduce.exs

defmodule MyList do
  def reduce([], value, _func) do
    value
  end

  def reduce([ head | tail ], value, func) do
    reduce(tail, func.(head, value), func)
  end
end
