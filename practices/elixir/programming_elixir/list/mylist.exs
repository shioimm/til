# プログラミングElixir 7.2 list/mylist.exs

defmodule MyList do
  def len([]),           do: 0
  def len([head|tail]) , do: 1 + len(tail)
end
