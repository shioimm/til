# https://exercism.org/tracks/ruby/exercises/leap

class Year
  def self.leap?(year)
    (year % 400).zero? || ((year % 4).zero? && !(year % 100).zero?)
  end
end
