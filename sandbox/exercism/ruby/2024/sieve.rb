class Sieve
  def initialize(number)
    @number = number
  end

  def primes
    (2..@number).inject([]) { |result, n|
      if result.any? { |prime| (n % prime).zero? }
        result
      else
        result.push n
      end
    }
  end
end
