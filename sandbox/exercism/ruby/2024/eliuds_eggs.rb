# https://exercism.org/tracks/ruby/exercises/eliuds-eggs

class EliudsEggs
  def self.egg_count(number)
    count = 0

    loop do
      q, r = number.divmod 2
      count += r
      number = q
      break count if number.zero?
    end
  end
end
