# Binary from https://exercism.io↲

using Module.new {
  refine String do
    def invalid_as_binary?
      self.match?(/[^01]/)
    end
  end
}

class Binary
  def self.to_decimal(string)
    raise ArgumentError if string.invalid_as_binary?

    string.chars
          .reverse
          .map
          .with_index { |char, index| char.to_i * (2 ** index) }
          .sum
  end
end
