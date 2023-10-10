# プログラミングElixir 6.9 mm/import.exs

defmodule Example do
  def func1 do
    List.flatten [1, [2, 3], 4]
  end

  def func2 do
    import List, only: [flatten: 1]
    flatten [5, [6, 7], 8]
  end
end
