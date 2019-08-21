# Matrix from https://exercism.io

class Matrix
  attr_reader :rows, :columns

  def initialize(numbers)
    @rows = numbers.lines.map { |n| n.split.map(&:to_i) }
    @columns = rows.transpose
  end
end
