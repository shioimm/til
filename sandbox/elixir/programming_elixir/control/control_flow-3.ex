# プログラミングElixir 12.6 ControlFlow-3

defmodule MyModule do
  def ok!(execution) do
    case execution do
      { :ok, data } -> data
      { :error, message } -> raise "Failed to open file: #{message}"
    end
  end
end

IO.inspect MyModule.ok! File.open("somefile")
IO.inspect MyModule.ok! File.open("nofile")
