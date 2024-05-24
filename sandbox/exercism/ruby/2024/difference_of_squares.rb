class Squares
  def initialize(n)
    @to = n
  end

  def square_of_sum
    (1..@to).sum ** 2
  end

  def sum_of_squares
    (1..@to).sum { |n| n ** 2 }
  end

  def difference
    square_of_sum - sum_of_squares
  end
end
