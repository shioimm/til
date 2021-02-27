# プログラミングElixir 10.2 enum/stream1.exs

[1, 2, 3, 4]
|> Stream.map(&(&1 * &1))
  # #Stream<[enum: [1, 2, 3, 4],
  #   funs: [#Function<49.119101820/1 in Stream.map/2>]]>
|> Stream.map(&(&1 + 1))
  # #Stream<[enum: [1, 2, 3, 4],
  #   funs: [#Function<49.119101820/1 in Stream.map/2>,
  #   #Function<49.119101820/1 in Stream.map/2>]
|> Stream.filter(fn x -> rem(x, 2) == 1 end)
  # #Stream<[enum: [1, 2, 3, 4],
  #   funs: [#Function<49.119101820/1 in Stream.map/2>,
  #          #Function<49.119101820/1 in Stream.map/2>,
  #          #Function<41.119101820/1 in Stream.filter/2>]
|> Enum.to_list
|> IO.inspect # [5, 17]
