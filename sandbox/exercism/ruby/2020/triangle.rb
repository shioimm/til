# Triangle Age from https://exercism.io

class Triangle
  def initialize(sides)
    @sides = sides
  end

  def equilateral?
    valid? && sides.uniq.size.eql?(1)
  end

  def isosceles?
    valid? && sides.uniq.size <= 2
  end

  def scalene?
    valid? && sides.uniq.size.eql?(3)
  end

  private

    attr_reader :sides

    def valid?
      triangle? && not_degenerate?
    end

    def triangle?
      !sides.include?(0)
    end

    def not_degenerate?
      sides.max <= sides.min(2).sum
    end
end
