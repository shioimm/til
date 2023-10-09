# プログラミングElixir 10.2

Stream.iterate(0, &(&1 + 1))
|> Enum.take(5)
|> IO.inspect

Stream.iterate(2, &(&1 * &1))
|> Enum.take(5)
|> IO.inspect

Stream.iterate([], &[&1])
|> Enum.take(5)
|> IO.inspect
