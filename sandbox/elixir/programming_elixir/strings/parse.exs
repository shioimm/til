# プログラミングElixir 11.3 strings/parse.exs

defmodule Parse do
  def number([?- | tail]) do
    _number_digits(tail, 0) * -1
  end

  def number([?+ | tail]) do
    _number_digits(tail, 0)
  end

  def number(str) do
    _number_digits(str, 0)
  end

  defp _number_digits([], value) do
    value
  end

  defp _number_digits([digit | tail], value)
  when digit in '0123456789' do
    _number_digits(tail, value * 10 + digit - ?0)
  end

  defp _number_digits([non_digit | _], _) do
    raise "Invalid digit '#{[non_digit]}'"
  end
end

IO.puts Parse.number('123')
IO.puts Parse.number('-123')
IO.puts Parse.number('+123')
IO.puts Parse.number('+9')
IO.puts Parse.number('+a')
