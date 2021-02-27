# プログラミングElixir 10.2

Stream.resource(fn -> File.open!("sample") end,
                fn file -> case IO.read(file, :line) do
                  data when is_binary(data) -> { [data], file }
                  _ -> { :halt, file }
                end,
                fn file -> File.close(file) end)
