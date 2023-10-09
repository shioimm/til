# Prime Factors from https://exercism.io

require 'prime'

class PrimeFactors
  def self.of(total)
    return [] if total <= 1

    (2..total).each_with_object([]) do |n, arr|
      quot, rem = total.divmod(n)

      while rem.zero?
        arr << n if n.prime?
        quot, rem = quot.divmod(n)
      end
    end
  end
end
