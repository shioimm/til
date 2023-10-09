# Armstrong Number from https://exercism.io

class ArmstrongNumbers
  def self.include?(number)
    number.digits.sum { |n| n ** number.digits.size } == number
  end
end

# Integer#digits
# https://docs.ruby-lang.org/ja/2.6.0/method/Integer/i/digits.html
