# https://exercism.org/tracks/ruby/exercises/pangram

class Pangram
  LETTERS = ('a'..'z').to_a.freeze

  class << self
    def pangram?(sentence)
      chars = sentence.downcase.scan(/\w/)
      (LETTERS - chars).empty?
    end
  end
end
