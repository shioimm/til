# プログラミングElixir 8.7 maps/dynamic_nested.exs

nested = %{
  butter_cup: %{
    actor: %{
      first: "Robin",
      second: "Wright"
    },
    role: "princess"
  },
  westly: %{
    actor: %{
      first: "Cary",
      second: "Ewes"
    },
    role: "farm boy"
  }
}

IO.inspect get_in(nested, [:butter_cup])
IO.inspect get_in(nested, [:butter_cup, :actor])
IO.inspect get_in(nested, [:butter_cup, :actor, :first])
IO.inspect put_in(nested, [:westly, :actor, :last], "Elwes")
