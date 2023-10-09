# プログラミングElixir 15.1 spawn/fact_tr.exs

defmodule TailRecursive do
  def factorial(n) do
    _fact(n, 1)
  end

  def _fact(0, acc) do
    acc
  end

  def _fact(n, acc) do
    _fact(n - 1, acc * n)
  end
end
