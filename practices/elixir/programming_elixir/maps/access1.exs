# プログラミングElixir 8.7 maps/access1.exs

cast = [
  %{
    charactor: "Buttercup",
    actor: %{
      first: "Robin",
      last: "Wright"
    },
    role: "princess"
  },
  %{
    charactor: "Westley",
    actor: %{
      first: "Cary",
      last: "Ewes"
    },
    role: "farm boy"
  }
]

IO.inspect get_in(cast, [Access.all(), :charactor])
IO.inspect get_in(cast, [Access.at(1), :role])
IO.inspect get_and_update_in(cast,
                             [Access.all(), :actor, :last],
                             &({ &1, String.upcase(&1) }))
