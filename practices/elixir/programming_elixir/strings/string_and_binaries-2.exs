# プログラミングElixir 11.3 StringsAndBinaries-2

defmodule MyString do
  def anagram?(str1, str2) do
    Enum.sort(str1) == Enum.sort(str2)
  end
end

IO.inspect MyString.anagram?('silent', 'listen')
IO.inspect MyString.anagram?('silent', 'loud')
