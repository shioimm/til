# プログラミングElixir 8.7 maps/access2.exs

cast = [
  %{
    charactor: "Buttercup",
    actor: { "Robin", "Wright" },
    role: "princess"
  },
  %{
    charactor: "Westley",
    actor: { "Cary", "Ewes" },
    role: "farm boy"
  }
]

IO.inspect get_in(cast, [Access.all(), :actor, Access.elem(1)])
IO.inspect get_and_update_in(cast,
                             [Access.all(), :actor, Access.elem(1)],
                             &({ &1, String.reverse(&1) }))
