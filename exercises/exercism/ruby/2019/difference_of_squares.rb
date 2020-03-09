# Difference Of Squares from https://exercism.io

class Squares
  def initialize(number)
    @from = 1
    @to = number
  end

  def square_of_sum
    (from..to).sum ** 2
  end

  def sum_of_squares
    (from..to).sum { |n| n ** 2 }
  end

  def difference
    square_of_sum - sum_of_squares
  end

  private

    attr_reader :from, :to
end

# alias_method Integer#**, Integer#pow
