# https://exercism.org/tracks/ruby/exercises/matrix

class Matrix
  def initialize(string)
    @string = string
  end

  def rows
    @rows ||= @string.each_line.inject([]) { |rows, str| rows << str.split.map(&:to_i) }
  end

  def columns
    @columns ||= rows.transpose
  end
end
