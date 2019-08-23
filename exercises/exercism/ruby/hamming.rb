# Hamming from https://exercism.io

class Hamming
  def self.compute(x, y)
    self.new(x, y).compute
  end

  def initialize(x, y)
    @x, @y = x, y
  end

  def compute
    raise ArgumentError if x.length != y.length

    x.chars.zip(y.chars).count { |xx, yy| xx != yy }
  end

  private

    attr_reader :x, :y
end

# Array#zip
# https://docs.ruby-lang.org/ja/2.6.0/method/Array/i/zip.html
# Enumerable#count
# https://docs.ruby-lang.org/ja/2.6.0/method/Enumerable/i/count.html
# ブロックを渡すことができる
