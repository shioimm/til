# https://exercism.org/tracks/ruby/exercises/triangle

class Triangle
  Shape = Data.define(:kind, :number_of_same_sides)

  SHAPES = [
    Shape.new(:equilateral, 1),
    Shape.new(:isosceles, 2),
    Shape.new(:scalene, 3),
  ]

  def initialize(sides)
    @sides = sides
  end

  SHAPES.each do |shape|
    define_method("#{shape.kind}?") do
      return false if self.invalid?

      if shape.kind == :isosceles
        shape.number_of_same_sides >= @sides.uniq.size
      else
        shape.number_of_same_sides == @sides.uniq.size
      end
    end
  end

  private

  def invalid?
    @sides.any?(&:zero?) || @sides.max > @sides.min(2).sum
  end
end
