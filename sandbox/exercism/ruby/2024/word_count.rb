# https://exercism.org/tracks/ruby/exercises/word-count

class Phrase
  def initialize(words)
    @words = words
  end

  def word_count
    @words.downcase
          .scan(/\b[\w']+\b/)
          .each_with_object(Hash.new(0)) { |word, result| result[word] += 1 }
  end
end
