# プログラミングElixir 6.5 mm/default_params2.exs

defmodule Params do
  def func(p1, p2 \\ 123)

  def func(p1, p2) when is_list(p1) do
    "You said #{p2} with a list"
  end

  def func(p1, p2) do
    "You passed in #{p1} and #{p2}"
  end
end

IO.puts Params.func(99)
IO.puts Params.func(99, "cat")
IO.puts Params.func([99])
IO.puts Params.func([99], "dog")
