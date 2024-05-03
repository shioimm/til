# https://exercism.org/tracks/ruby/exercises/series

class Series
  def initialize(string)
    @string = string
  end

  def slices(digit)
    raise ArgumentError if digit > @string.size || 0 >= digit || @string.empty?

    @string.chars.each_cons(digit).map(&:join)
  end
end
