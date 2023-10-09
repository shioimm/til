# プログラミングElixir 6.3 mm/factorial2.exs

class Factorial
  def of(n)
    raise if n.negative?

    n.zero? ? 1 : n * of(n - 1)
  end
end
