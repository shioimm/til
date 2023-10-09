# プログラミングElixir 15.2 spawn/chain.exs

defmodule Chain do
  def counter(next_pid) do
    receive do
      n -> send next_pid, n + 1
    end
  end

  def create_processes(n) do
    code_to_run = fn (_, send_to) ->
      spawn(Chain, :counter, [send_to])
    end

    last = Enum.reduce(1..n, self(), code_to_run)
    send(last, 0)

    receive do
      final_answer when is_integer(final_answer) -> "Result is #{inspect(final_answer)}"
    end
  end

  def run(n) do
    :timer.tc(Chain, :create_processes, [n]) |> IO.inspect
  end
end

# $ exs -r chain.exs -e Chain.run(10)
#   => {1889, "Result is 10"}
# exs --erl "+P 1000000" -r chain.exs -e  "Chain.run(1000000)"
#   => {2349586, "Result is 1000000"}
