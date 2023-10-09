# プログラミングElixir 10.3

Enum.into 1..5, [] |> IO.inspect

Enum.into IO.stream(:stdio, :line), IO.stream(:stdio, :line)
