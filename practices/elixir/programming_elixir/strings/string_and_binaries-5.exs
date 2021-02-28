# プログラミングElixir 11.3 StringsAndBinaries-5

defmodule MyString do
  def center([]) do
    codepoints = Enum.to_list 65..125
  end
end

IO.puts MyString.center(["cat", "zebra", "elephant"])
