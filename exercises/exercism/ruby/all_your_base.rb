# All Your Base from https://exercism.io

class BaseConverter
  def self.convert(input_base, digits, output_base)
    new(input_base, digits, output_base).convert
  end

  def initialize(input_base, digits, output_base)
    @input_base  = input_base
    @digits      = digits
    @output_base = output_base
    @decimal     = convert_digits_to_decimal
  end

  def convert
    raise ArgumentError if any_attributes_invalid?
    return [0] if digits_empty?

    [].tap do |result|
      while @decimal > 0
        result << @decimal % output_base
        @decimal /= output_base
      end
    end.then do |result|
      result.reverse
    end
  end

  private

    attr_reader :input_base, :digits, :output_base

    def convert_digits_to_decimal
      digits.reverse.map.with_index { |n, i| n * input_base ** i }.sum
    end

    def digits_empty?
      digits.empty? || digits.all?(0)
    end

    def any_attributes_invalid?
      digits.any?(&:negative?) \
        || digits.any? { |n| n >= input_base } \
        || 2 > input_base \
        || 2 > output_base
    end
end

# 参照: [基数変換まとめ](https://www.deep-rain.com/programming/computer-science/137)
