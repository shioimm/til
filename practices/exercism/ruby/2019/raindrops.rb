# Raindrops from https://exercism.io

class Raindrops
  SOUNDS = {
    3 => 'Pling',
    5 => 'Plang',
    7 => 'Plong'
  }.freeze

  def self.convert(number)
    new(number).convert
  end

  def initialize(number)
    @number = number
  end

  def convert
    SOUNDS.inject('') { |result, (k, v)| (number % k).zero? ? result << v : result }
          .then { |sounds| sounds.empty? ? number.to_s : sounds }
  end

  private

    attr_reader :number
end
