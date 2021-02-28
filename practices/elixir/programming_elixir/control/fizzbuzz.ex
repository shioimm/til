# プログラミングElixir 12.2 control/fizzbuzz.ex

defmodule FizzBuzz do
  def upto(n)
  when n > 0 do
    _upto(1, n, [])
  end

  defp _upto(_current, 0, result) do
    Enum.reverse result
  end

  defp _upto(current, left, result) do
    next_answer = cond do
      rem(current, 3) == 0 and rem(current, 5) == 0 -> "FizzBuzz\n"
      rem(current, 3) == 0 -> "Fizz\n"
      rem(current, 5) == 0 -> "Buzz\n"
      true -> "#{current}\n"
    end
    _upto(current + 1, left - 1, [next_answer | result])
  end
end

IO.puts FizzBuzz.upto(20)
