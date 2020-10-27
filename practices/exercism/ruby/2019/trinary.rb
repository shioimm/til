# Trinary from https://exercism.io

class Trinary
  def initialize(string)
    @string = string
  end

  def to_decimal
    return 0 if string.match?(/[^012]/)

    string.chars.reverse.map.with_index { |s, index| s.to_i * 3 ** index }.sum
  end

  private

    attr_reader :string
end
