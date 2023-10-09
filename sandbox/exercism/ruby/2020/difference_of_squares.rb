# Difference Of Squares from https://exercism.io

class Squares
  def initialize(max)
    @min = 1
    @max = max
  end

  def square_of_sum
    (min..max).sum ** 2
  end

  def sum_of_squares
    (min..max).sum { |n| n ** 2 }
  end

  def difference
    square_of_sum - sum_of_squares
  end

  private

    attr_reader :min, :max
end
