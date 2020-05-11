# Sum Of Multiples from https://exercism.io

class SumOfMultiples
  def initialize(*base)
    @base = base
  end

  def to(max)
    return 0 if base.sum.zero?

    base.flat_map { |n| n.step(by: n, to: max - 1).map(&:itself) }.uniq.sum
  end

  private

    attr_reader :base
end
