# Largest Series Product from https://exercism.io

class Series
  def initialize(string)
    @string = string
    @max    = 0
  end

  def largest_product(digit)
    raise ArgumentError if string.match(/[A-z]/) || digit > numbers.size
    return 1 if digit.zero?

    numbers.each_cons(digit) do |list|
      @max = list.inject(&:*) if list.inject(&:*) > @max
    end.then do
      @max
    end
  end

  private

    attr_reader   :string
    attr_accessor :max

    def numbers
      string.chars.map(&:to_i)
    end
end

# Enumerable#each_cons
# https://docs.ruby-lang.org/ja/2.6.0/method/Enumerable/i/each_cons.html
