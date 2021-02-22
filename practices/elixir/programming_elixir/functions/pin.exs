# プログラミングElixir 5.4 functions/pin.exs

defmodule Greeter do
  def for(name, greeting) do
    fn
      (^name) -> "#{greeting} #{name}"
      (_)     -> "I don't know"
    end
  end
end

mr_valim = Greeter.for("World", "Hello,")

IO.puts mr_valim.("World")
IO.puts mr_valim.("Everyone")
