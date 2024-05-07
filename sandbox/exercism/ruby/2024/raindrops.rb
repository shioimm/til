# https://exercism.org/tracks/ruby/exercises/raindrops

class Raindrops
  SOUNDS = {
    3 => 'Pling',
    5 => 'Plang',
    7 => 'Plong',
  }.freeze

  def self.convert(number)
    sounds = SOUNDS.map { |n, sound| sound if (number % n).zero? }
    sounds.any? ? sounds.join : number.to_s
  end
end
