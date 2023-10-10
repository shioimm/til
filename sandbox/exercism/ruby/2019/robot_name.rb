# Robot Name from https://exercism.io

class Robot
  attr_reader :name

  def self.forget
    @@names = ('AA000'..'ZZ999').to_a.shuffle
  end

  def initialize
    reset
  end

  def reset
    @name = @@names.pop
  end
end

# Array#shuffle
# https://docs.ruby-lang.org/ja/2.6.0/method/Array/i/shuffle.html
# 引数にRandomオブジェクトを渡すと疑似乱数列を用いることができる
