# プログラミングElixir 11.3 StringsAndBinaries-5

defmodule MyString do
  def center(list) do
    longest_size = Enum.map(list, &(String.length &1)) |> Enum.max

    Enum.each(list, fn str ->
      size = round((longest_size - String.length str)  / 2)
      spaces = String.duplicate(" ", size)
      "#{spaces}#{str}#{spaces}" |> IO.puts
    end)
  end
end

MyString.center(["cat", "zebra", "elephant"])
