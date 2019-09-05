# Pangram from https://exercism.io

class Pangram
  ALPHABETS = ('a'..'z').to_a.freeze

  def self.pangram?(sentence)
    ALPHABETS == sentence.downcase.scan(/[a-z]/).sort.uniq
  end
end

# Set
# https://docs.ruby-lang.org/ja/2.6.0/class/Set.html
