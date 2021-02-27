# プログラミングElixir 10.2 enum/longest_line.exs

IO.puts File.read!("/usr/share/dict/words")
        |> String.split
        |> Enum.max_by(&String.length/1)
