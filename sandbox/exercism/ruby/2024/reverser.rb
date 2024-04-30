# https://exercism.org/tracks/ruby/exercises/reverse-string

module Reverser
  def self.reverse(string)
    string.chars.inject("") { |result, char| char + result }
  end
end
