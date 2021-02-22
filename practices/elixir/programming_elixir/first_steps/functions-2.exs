# プログラミングElixir 5.2 Functions-2

fizz_buzz = fn
  (0, 0, _) -> "FizzBuzz"
  (0, _, _) -> "Fizz"
  (_, _, arg) -> arg
end

IO.puts fizz_buzz.(0, 0, 1)
IO.puts fizz_buzz.(0, 1, 2)
IO.puts fizz_buzz.(1, 2, 3)
