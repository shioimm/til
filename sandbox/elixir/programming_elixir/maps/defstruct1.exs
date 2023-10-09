# プログラミングElixir 8.6 maps/defstruct1.exs

defmodule Attendee do
  defstruct name: "", paid: false, over_18: true

  def may_attend_after_party(attendee = %Attendee {}) do
    attendee.paid && attendee.over_18
  end

  def print_vip_badge(%Attendee { name: name }) when name != "" do
    IO.puts "Very cheap badge for #{name}"
  end

  def print_vip_badge(%Attendee {}) do
    raise "missing name for badge"
  end
end

# a1 = %Attendee{name: "Dave", over_18: true} => %Attendee{name: "Dave", over_18: true, paid: false}
# Attendee.may_attend_after_party a1          => false
# a2 = %Attendee{a1 | paid: true}             => %Attendee{name: "Dave", over_18: true, paid: true}
# Attendee.may_attend_after_party a2          => true
# Attendee.print_vip_badge a2                 => Very cheap badge for Dave+ :ok
