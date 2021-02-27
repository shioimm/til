# プログラミングElixir 10.2

Stream.unfold({ 0, 1 }, fn { f1, f2 } -> { f1, { f2, f1 + f2 }} end)
|> Enum.take(50)
|> IO.inspect
