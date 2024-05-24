# https://exercism.org/tracks/ruby/exercises/anagram

class Anagram
  def initialize(word)
    @word = word
    @chars = word.downcase.chars.sort
  end

  def match(candidates)
    candidates.select { |c| !c.casecmp?(@word) && c.downcase.chars.sort == @chars }
  end
end
