# Collatz Conjecture from https://exercism.io

class CollatzConjecture
  class << self
    def steps(number, count = 0)
      raise ArgumentError if number <= 0

      number == 1 ? count : steps(calculate_with(number), count += 1)
    end

    private

      def calculate_with(number)
        number.odd? ? number * 3 + 1 : number / 2
      end
  end
end
