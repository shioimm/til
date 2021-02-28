# プログラミングElixir 12.2 control/fizzbuzz1.ex

defmodule FizzBuzz do
  def upto(n)
  when n > 0 do
    _downto(n, [])
  end

  defp _downto(0, result) do
    result
  end

  defp _downto(current, result) do
    next_answer = cond do
      rem(current, 3) == 0 and rem(current, 5) == 0 -> "FizzBuzz\n"
      rem(current, 3) == 0 -> "Fizz\n"
      rem(current, 5) == 0 -> "Buzz\n"
      true -> "#{current}\n"
    end
    _downto(current - 1, [next_answer | result])
  end
end

IO.puts FizzBuzz.upto(20)
