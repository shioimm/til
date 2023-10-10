# プログラミングElixir 5.3 Functions-4

prefix = fn
  str1 -> (fn
    str2 -> "#{str1} #{str2}"
  end)
end

mrs = prefix.("Mrs")
IO.puts mrs.("Robinson")
IO.puts prefix.("Elixir").("Rocks")
