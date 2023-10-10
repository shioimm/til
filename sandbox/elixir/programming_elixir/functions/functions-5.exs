# プログラミングElixir 5.4 Functions-5

# Enum.map [1, 2, 3, 4], fn x -> x + 2 end
Enum.map [1, 2, 3, 4], &(&1 + 1)

# Enum.each [1, 2, 3, 4], fn x -> IO.inspect x end
Enum.each [1, 2, 3, 4], &(IO.inspect &1)
