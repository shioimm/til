# Trinary from https://exercism.io↲

using Module.new {
  refine String do
    def invalid_as_trinary?
      self.match?(/[^012]/)
    end
  end
}

class Trinary
  def initialize(string)
    @string = string
  end

  def to_decimal
    return 0 if string.invalid_as_trinary?

    string.chars
          .reverse
          .map
          .with_index { |str, i| str.to_i * (3 ** i) }
          .sum
  end

  private

    attr_reader :string
end
