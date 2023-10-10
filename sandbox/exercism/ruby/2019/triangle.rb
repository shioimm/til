# Triangle from https://exercism.io

class Triangle
  NUMBER_OF_SAME_SIDES = {
    equilateral: 1,
    isosceles: 2,
    scalene: 3
  }.freeze

  def initialize(sides)
    @sides = sides
  end

  NUMBER_OF_SAME_SIDES.each do |kind, number|
    define_method("#{kind}?") do
      return false if invalid_triangle?
      return true  if kind == :isosceles && equilateral?

      sides.uniq.size == number
    end
  end

  private

    attr_reader :sides

    def invalid_triangle?
      sides.include?(0) || sides.max > sides.min(2).sum
    end
end
