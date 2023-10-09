# プログラミングElixir 12.6 ControlFlow-1

defmodule FizzBuzz do
  def upto(n)
  when n > 0 do
    1..n |> Enum.map(&fizzbuzz/1)
  end

  defp fizzbuzz(n) do
    _fizzword(n, rem(n, 3), rem(n, 5))
  end

  defp _fizzword(x, y, z) do
    case { x, y, z } do
      { _, 0, 0 } -> "FizzBuzz\n"
      { _, 0, _ } -> "Fizz\n"
      { _, _, 0 } -> "Buzz\n"
      _ -> "#{x}\n"
    end
  end
end

IO.puts FizzBuzz.upto(20)
