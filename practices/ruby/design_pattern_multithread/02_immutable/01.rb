# Java言語で学ぶデザインパターン入門 マルチスレッド編 第2章

class Person
  def initialize
    @name = 'Alice'
    @address = 'Alaska'
  end

  def to_str
    "Name: #{name}, Address: #{address}"
  end

  private

    attr_reader :name, :address
end

alice = Person.new

10.times.map {
  Thread.fork {
    loop do
      sleep rand
      p alice.to_str
    end
  }
}.map(&:join)
