# プログラミングElixir 11.3 StringsAndBinaries-1

defmodule MyString do
  def printable?(str) do
    Enum.all?(str, &(&1 in Enum.to_list 65..125))
  end
end

IO.inspect MyString.printable?('{text}')
IO.inspect MyString.printable?([1, 2, 3, 4, 5])
