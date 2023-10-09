# プログラミングElixir 10.1 ListsAndRecursion-5

defmodule MyEnum do
  def all?([], _) do
    true
  end

  def all?([head | tail], func) do
    if func.(head) do
      all?(tail, func)
    else
      false
    end
  end

  def each([], _) do
    []
  end

  def each([head | tail], func) do
    [func.(head) | each(tail, func)]
  end

  def filter([], _) do
    []
  end

  def filter([head | tail], func) do
    if func.(head) do
      [head | filter(tail, func)]
    else
      []
    end
  end

  def take(list, 0) do
    []
  end

  def take([head | tail], n) do
    [head | take(tail, n - 1)]
  end

  def split(list, n) do
    { take(list, n), list -- take(list, n) }
  end
end

IO.inspect MyEnum.all?([1, 2, 3], &(&1 > 0))
IO.inspect MyEnum.all?([1, 2, 3], &(&1 > 3))
IO.inspect MyEnum.each(["a", "b", "c"], &String.upcase/1)
IO.inspect MyEnum.filter([1, 2, 3], &(&1 > 0))
IO.inspect MyEnum.filter([1, 2, 3], &(&1 > 3))
IO.inspect MyEnum.take([1, 2, 3], 0)
IO.inspect MyEnum.take([1, 2, 3], 3)
IO.inspect MyEnum.split([1, 2, 3], 1)
IO.inspect MyEnum.split([1, 2, 3], 2)
