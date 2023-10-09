# Sieve from https://exercism.io

class Sieve
  def initialize(number)
    @number = number
  end

  def primes
    (2..number).each_with_object([]) do |n, arr|
      arr << n if (2..n - 1).all? { |nn| n % nn != 0 }
    end
  end

  private

    attr_reader :number
end
