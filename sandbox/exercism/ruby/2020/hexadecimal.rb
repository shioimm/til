# Hexadecimal from https://exercism.io↲

using Module.new {
  refine String do
    def invalid_as_hexadecimal?
      self.match?(/[A-Zg-z]/)
    end
  end
}

class Hexadecimal
  NUMBERS = ('0'..'f').to_a.select { |str| str.match?(/[0-9a-f]/) }

  def initialize(string)
    @string = string
  end

  def to_decimal
    return 0 if string.invalid_as_hexadecimal?

    string.chars
          .reverse
          .map
          .with_index { |str, i| NUMBERS.index(str) * (16 ** i) }
          .sum
  end

  private

    attr_reader :string
end
