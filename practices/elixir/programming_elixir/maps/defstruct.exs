# プログラミングElixir 8.6 maps/defstruct.exs

defmodule Subscriber do
  defstruct name: "", paid: false, over_18: true
end

# s1 = %Subscriber {}
# s2 = %Subscriber { name: "Dave" }
# s3 = %Subscriber { name: "Mary", paid: true }
# IO.puts s3.name
#
# %Subscriber { name: a } = s3
# IO.puts a
#
# s4 = Subscriber { s3 | name: "Marie" }
# IO.puts s4.name
