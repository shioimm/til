# Nth Prime from https://exercism.io

module IntegerExt
  refine Integer do
    def prime?
      return false if self == 1
      (2..self - 1).all? { |n| self % n != 0 }
    end
  end
end

using IntegerExt

class Prime
  def self.nth(number)
    raise ArgumentError if number.zero?
    count = 0

    (1..).each do |n|
      count += 1 if n.prime?
      return n if count == number
    end
  end
en
