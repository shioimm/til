# プログラミングElixir 5.2 first-steps/handle_open.exs

handle_open = fn
  { :ok, file } -> "OK: #{IO.read(file, :line)}"
  { _, error } -> "Error: #{:file.format_error(error)}"
end

IO.puts handle_open.(File.open("../intro/hello.exs"))
IO.puts handle_open.(File.open("./noexistent"))
