# プログラミングElixir 6.5 mm/default_params1.exs

defmodule DefaultParams1 do
  def func(p1, p2 \\ 123) do
    IO.inspect [p1, p2]
  end

  def func(p1, 99) do
    IO.inspect "You said 99"
  end
end

# warning: variable "p1" is unused (if the variable is not meant to be used, prefix it with an underscore)
#   default_params1.exs:8: DefaultParams1.func/2
#
# warning: def func/2 has multiple clauses and also declares default values. In such cases, the default values should be defined in a header. Instead of:
#
#     def foo(:first_clause, b \\ :default) do ... end
#     def foo(:second_clause, b) do ... end
#
# one should write:
#
#     def foo(a, b \\ :default)
#     def foo(:first_clause, b) do ... end
#     def foo(:second_clause, b) do ... end
#
#   default_params1.exs:8
#
# warning: this clause cannot match because a previous clause at line 4 always matches
#   default_params1.exs:8
