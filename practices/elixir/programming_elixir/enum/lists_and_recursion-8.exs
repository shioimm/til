# プログラミングElixir 10.4 ListsAndRecursion-8

tax_rates = [ NC: 0.075, TX: 0.08 ]

orders = [
  [ id: 123, ship_to: :NC, net_amount: 100.00 ],
  [ id: 124, ship_to: :OK, net_amount: 35.50 ],
  [ id: 125, ship_to: :TX, net_amount: 24.00 ],
  [ id: 126, ship_to: :TX, net_amount: 44.80 ],
  [ id: 127, ship_to: :NC, net_amount: 25.00 ],
  [ id: 128, ship_to: :MA, net_amount: 10.00 ],
  [ id: 129, ship_to: :CA, net_amount: 102.00 ],
  [ id: 130, ship_to: :NC, net_amount: 50.00 ]
]

defmodule Orders do
  def with_tolal_amount(tax_rates, orders) do
    orders |> Enum.map(&(with_tax(&1, tax_rates)))
  end

  defp with_tax([id: n, ship_to: code, net_amount: amount], tax_rates) do
    tax = (get_tax_rate(tax_rates, code) || 0) + 1
    [ id: n, ship_to: code, net_amount: amount, total_amount: amount * tax ]
  end

  defp get_tax_rate(tax_rates, code) do
    Keyword.get(tax_rates, code)
  end
end

Orders.with_tolal_amount(tax_rates, orders) |> IO.inspect
