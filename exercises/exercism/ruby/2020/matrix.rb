# Matrix from https://exercism.io

class Matrix
  def initialize(numbers)
    @numbers = numbers
  end

  def rows
    numbers.each_line.map { |n| n.split.map(&:to_i) }
  end

  def columns
    rows.transpose
  end

  private

    attr_reader :numbers
end
