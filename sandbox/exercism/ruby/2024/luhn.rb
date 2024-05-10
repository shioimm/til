# https://exercism.org/tracks/ruby/exercises/luhn

class Luhn
  MINIMUM_LENGTH = 1
  MAXIMUM_NUMBER = 9
  DIVISOR = 10

  def self.valid?(str)
    new(str).valid?
  end

  def initialize(str)
    @digits = str.tr(' ', '')
  end

  def valid?
    all_digits_numbers? && more_than_minimum_length? && enable_to_divide?
  end

  private

  def all_digits_numbers?
    !@digits.match?(/[^0-9]/)
  end

  def more_than_minimum_length?
    @digits.size > MINIMUM_LENGTH
  end

  def enable_to_divide?
    sum = @digits.chars.reverse_each.with_index(1).sum { |digit, i|
      if i.even?
        (digit.to_i * 2).then { |d| d > MAXIMUM_NUMBER ? d - MAXIMUM_NUMBER : d }
      else
        digit.to_i
      end
    }

    (sum % DIVISOR).zero?
  end
end
