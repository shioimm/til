# Binary from https://exercism.io

class Binary
  def self.to_decimal(char)
    raise ArgumentError if char.match? /[^01]/

    char.to_i(2)
  end
end
