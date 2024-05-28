# https://exercism.org/tracks/ruby/exercises/sum-of-multiples

class SumOfMultiples
  def initialize(*base_values)
    @base_values = base_values
  end

  def to(level)
    return 0 if @base_values.all?(&:zero?)

    @base_values.flat_map { |base| (base...level).select { (_1 % base).zero? } }.uniq.sum
  end
end
