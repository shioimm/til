# https://exercism.org/tracks/ruby/exercises/acronym

module Acronym
  def self.abbreviate(word)
    word.scan(/\b\w/).inject("") { |result, char| result += char.upcase }
  end
end
