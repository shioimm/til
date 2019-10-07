# ISBN Verifier from https://exercism.io

using Module.new {
  refine String do
    def to_i_with_x
      match?(/X/) ? 10 : to_i
    end
  end
}

class IsbnVerifier
  DIGITS = (10.downto 1).to_a
  DIVISOR = 11

  def self.valid?(string)
    new(string).valid?
  end

  def initialize(string)
    @numbers = convert_to_numbers(string)
  end

  def valid?
    return false if numbers.size != DIGITS.size

    sum.modulo(DIVISOR).zero?
  end

  private

    attr_reader :numbers

    def convert_to_numbers(string)
      string.scan(/\d|X\z/).map(&:to_i_with_x)
    end

    def sum
      numbers.zip(DIGITS).sum { |n, digit| n * digit }
    end
end
