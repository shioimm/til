# Hexadecimal from https://exercism.io

class Hexadecimal
  def initialize(string)
    @string = string
  end

  def to_decimal
    string.downcase.match?(/[g-z]/) ? 0 : string.to_i(16)
  end

  private

    attr_reader :string
end
