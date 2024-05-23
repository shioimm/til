class Triangle
  Triangle = Data.define(:shape, :number_of_same_sides)

  NUMBER_OF_SAME_SIDES = [
    Triangle.new(:equilateral, 1),
    Triangle.new(:isosceles, 2),
    Triangle.new(:scalene, 3),
  ]

  def initialize(sides)
    @sides = sides
  end

  NUMBER_OF_SAME_SIDES.each do |triangle|
    define_method("#{triangle.shape}?") do
      return false if self.invalid?
      return true if triangle.shape.eql?(:isosceles) && self.equilateral?

      @sides.uniq.size == triangle.number_of_same_sides
    end
  end

  private

  def invalid?
    @sides.any?(&:zero?) || @sides.max > @sides.min(2).sum
  end
end
