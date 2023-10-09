# プログラミングElixir 10.2 enum/countdown.exs

defmodule Countdown do
  def sleep(seconds) do
    receive do
      after seconds * 1000 -> nil
    end
  end

  def say(text) do
    spawn fn -> :os.cmd('espeak #{text}') end
  end

  def timer do
    Stream.resource(
      fn
        ->
          { _h, _m, s } = :erlang.time
          60 - s - 1
      end,
      fn
        0 ->
          { :halt, 0 }
        count ->
          sleep(1)
          { [inspect(count)], (count - 1) }
      end,
      fn
        _ ->
          nil
      end
    )
  end
end

# Countdown.timer
#   => #Function<55.119101820/2 in Stream.resource/3>
# counter = Countdown.timer
#   => #Function<55.119101820/2 in Stream.resource/3>
# printer = counter |> Stream.each(&IO.puts/1)
#   => #Stream<[
#        enum: #Function<55.119101820/2 in Stream.resource/3>,
#        funs: [#Function<40.119101820/1 in Stream.each/2>]
#      ]>
# speaker = printer |> Stream.each(&Countdown.say/1)
#   => #Stream<[
#        enum: #Function<55.119101820/2 in Stream.resource/3>,
#        funs: [#Function<40.119101820/1 in Stream.each/2>,
#         #Function<40.119101820/1 in Stream.each/2>]
#      ]>
# speaker |> Enum.take(2)
