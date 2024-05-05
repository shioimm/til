# https://exercism.org/tracks/ruby/exercises/hamming

class Hamming
  def self.compute(x, y)
    raise ArgumentError if x.size != y.size
    x.size.times.count { |i| x[i] != y[i] }
  end
end
