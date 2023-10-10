# プログラミングElixir 12.2 control/fizzbuzz3.ex

defmodule FizzBuzz do
  def upto(n)
  when n > 0 do
    1..n |> Enum.map(&fizzbuzz/1)
  end

  defp fizzbuzz(n) do
    _fizzword(n, rem(n, 3), rem(n, 5))
  end

  defp _fizzword(_n, 0, 0) do
    "FizzBuzz\n"
  end

  defp _fizzword(_n, 0, _) do
    "Fizz\n"
  end

  defp _fizzword(_n, _, 0) do
    "Buzz\n"
  end

  defp _fizzword(n, _, _) do
    "#{n}\n"
  end
end

IO.puts FizzBuzz.upto(20)
