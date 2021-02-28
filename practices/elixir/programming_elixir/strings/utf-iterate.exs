# プログラミングElixir 11.3 strings/utf-iterate.exs

defmodule Utf8 do
  def each(str, func)
  when is_binary(str) do
    _each(str, func)
  end

  defp _each(<< head::utf8, tail::binary >>, func) do
    func.(head)
    _each(tail,func)
  end

  defp _each(<<>>, _func) do
    []
  end
end

Utf8.each "abc", fn char -> IO.puts char end
