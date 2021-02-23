# プログラミングElixir 6.5 ModuleAndFunctions-5

defmodule Chop do
  def guess(actual, a..b) when actual == div(a + b, 2) do
    IO.puts actual
  end

  def guess(actual, a..b) when actual > div(a + b, 2) do
    tmp = div(a + b, 2)

    IO.puts "Is it #{tmp}"

    guess(actual, tmp..b)
  end

  def guess(actual, a..b) when actual < div(a + b, 2) do
    tmp = div(a + b, 2)

    IO.puts "Is it #{tmp}"

    guess(actual, a..tmp)
  end
end

Chop.guess(273, (1..1000))
