# プログラミングElixir 6.3 ModuleAndFunctions-4

defmodule ModuleAndFunctions do
  def sum(1), do: 1
  def sum(n), do: n + sum(n - 1)
end
