# Sum Of Multiples from https://exercism.io

class SumOfMultiples
  def initialize(*multiples)
    @multiples = multiples
  end

  def to(limit)
    return 0 if multiples == [0]

    (0...limit).select { |n| multiples.any? { |m| n % m == 0 } }.sum
  end


  private

    attr_reader :multiples
end
