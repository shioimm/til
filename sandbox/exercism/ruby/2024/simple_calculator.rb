# https://exercism.org/tracks/ruby/exercises/simple-calculator

class SimpleCalculator
  ALLOWED_OPERATIONS = ['+', '/', '*'].freeze

  class UnsupportedOperation < StandardError; end

  def self.calculate(first_operand, second_operand, operation)
    raise UnsupportedOperation unless ALLOWED_OPERATIONS.include? operation

    result = first_operand.send(operation, second_operand)
    "#{first_operand} #{operation} #{second_operand} = #{result}"
  rescue TypeError
    raise ArgumentError
  rescue ZeroDivisionError
    "Division by zero is not allowed."
  end
end
