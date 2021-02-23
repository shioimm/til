# プログラミングElixir 6.3 ModuleAndFunctions-5

defmodule ModuleAndFunctions do
  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, rem(x, y))
end
