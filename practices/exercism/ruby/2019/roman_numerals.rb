# Roman Numerals from https://exercism.io

module RomanNumeral
  ROMAN_LETTERS = {
    1000 => 'M',
    900  => 'CM',
    500  => 'D',
    400  => 'CD',
    100  => 'C',
    90   => 'XC',
    50   => 'L',
    40   => 'XL',
    10   => 'X',
    9    => 'IX',
    5    => 'V',
    4    => 'IV',
    1    => 'I',
  }

  def to_roman
    n = self

    ROMAN_LETTERS.each_with_object('') do |(int, letter), chars|
      chars << letter * (n / int)
      n %= int
    end
  end
end

class Integer
  include RomanNumeral
end
