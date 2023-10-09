# プログラミングElixir 6.9 mm/attributes.exs

defmodule Example do
  @musician "Patti Smith"

  def get_musician do
    @musician
  end
end

IO.puts Example.get_musician
