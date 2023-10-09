# プログラミングElixir 8.7 maps/access3.exs

cast = %{
  buttercup: %{
    actor: { "Robin", "Wright" },
    role: "princess"
  },
  westley: %{
    actor: { "Cary", "Ewes" },
    role: "farm boy"
  }
}

IO.inspect get_in(cast, [Access.key(:westley), :actor, Access.elem(1)])
IO.inspect get_and_update_in(cast,
                             [Access.key(:buttercup), :role],
                             &({ &1, "Queen" }))
