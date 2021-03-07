# プログラミングElixir 21.1 tasks/tasks1.exs

defmodule Fib do
  def of(0), do: 0
  def of(1), do: 1
  def of(n), do: Fib.of(n - 1) + Fib.of(n - 2)
end

IO.puts "Start the task"
worker = Task.async(fn -> Fib.of(20) end)

IO.puts "---"

result = Task.await(worker)
IO.puts "The result is #{result}"
