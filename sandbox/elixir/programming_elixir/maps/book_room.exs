# プログラミングElixir 8.4 maps/book_room.exs

people = [
  %{ name: "Grumpy",    height: 1.23 },
  %{ name: "Dave",      height: 1.88 },
  %{ name: "Dopey",     height: 1.32 },
  %{ name: "Shaquille", height: 2.16 },
  %{ name: "Sneezy",    height: 1.28 },
]

defmodule HotelRoom do
  def book(%{name: name, height: height})
  when height > 1.9 do
    IO.puts "Need extra-long bed for #{name}"
  end

  def book(%{name: name, height: height})
  when height < 1.3 do
    IO.puts "Need low shower controls for #{name}"
  end

  def book(person) do
    IO.puts "Need regular bed for #{person.name}"
  end
end

people |> Enum.each(&HotelRoom.book/1)
