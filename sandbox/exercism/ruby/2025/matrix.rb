# https://exercism.org/tracks/ruby/exercises/matrix

class Matrix
  def initialize(string)
    @string = string
  end

  def rows
    @string.each_line.map { it.split.map(&:to_i) }
  end

  def columns
    rows.transpose
  end
end
