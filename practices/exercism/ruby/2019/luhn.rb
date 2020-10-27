# Luhn from https://exercism.io

class Luhn
  def self.valid?(string)
    new(string).valid?
  end

  def initialize(string)
    @string = string
  end

  def valid?
    return false if numbers.length <= 1
    return false if string.match? /[^\d\s]/

    (checksum % 10).zero?
  end

  private

    attr_reader :string

    def numbers
      string.scan(/\d/).map(&:to_i)
    end

    def double(n)
      doubled = n * 2
      doubled > 9 ? doubled - 9 : doubled
    end

    def checksum
      numbers.reverse_each
             .with_index
             .sum { |num, index| index.odd? ? double(num) : num }
    end
end

# Array#sum
# https://docs.ruby-lang.org/ja/2.6.0/method/Array/i/sum.html
# ブロックを渡すことができる
