# プログラミングElixir 15.1 spawn/spawn-basic1.ex

defmodule Spawn1 do
  def greet do
    receive do
      { sender, msg } -> send sender, { :ok, "Hello, #{msg}" }
    end
  end
end

pid = spawn(Spawn1, :greet, [])
send pid, { self(), "World!" }

receive do
  { :ok, message } -> IO.puts message
end
