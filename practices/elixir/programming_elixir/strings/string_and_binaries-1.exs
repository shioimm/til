# プログラミングElixir 11.3 StringsAndBinaries-1

defmodule MyString do
  def printable?() do
    codepoints = Enum.to_list 65..125
  end
end

IO.puts MyString.printable?('{text}')
IO.puts MyString.printable?(12345)
