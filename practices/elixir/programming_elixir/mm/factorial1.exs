# プログラミングElixir 6.3 mm/factorial1.exs

defmodule Factorial do
  def of(0), do: 1
  def of(n), do: n * of(n - 1)
end
