# プログラミングElixir 10.2 enum/stream3.exs

IO.puts File.stream!("/usr/share/dict/words") |> Enum.max_by(&String.length/1)
