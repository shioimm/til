# プログラミングElixir 12.2 control/fizzbuzz2.ex

defmodule FizzBuzz do
  def upto(n)
  when n > 0 do
    1..n |> Enum.map(&fizzbuzz/1)
  end

  defp fizzbuzz(n) do
    cond do
      rem(n, 3) == 0 and rem(n, 5) == 0 -> "FizzBuzz\n"
      rem(n, 3) == 0 -> "Fizz\n"
      rem(n, 5) == 0 -> "Buzz\n"
      true -> "#{n}\n"
    end
  end
end

IO.puts FizzBuzz.upto(20)
