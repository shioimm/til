# Series from https://exercism.io

class Series
  def initialize(string)
    @string = string
  end

  def slices(digit)
    raise ArgumentError if digit > string.length

    string.chars.each_cons(digit).map(&:join)
  end

  private

    attr_reader :string
end
