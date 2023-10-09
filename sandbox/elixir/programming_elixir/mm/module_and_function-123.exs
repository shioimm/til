# プログラミングElixir 6.2 ModuleAndFunctions-1, 2, 3

defmodule Times do
  def double(n) do
    n * 2
  end

  def triple(n) do
    n * 3
  end

  def quadruple(n) do
    double(n) * 2
  end
end
