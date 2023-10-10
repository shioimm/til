# Pangram from https://exercism.io↲

class Pangram
  CHARACTERS = ('a'..'z').to_a

  def self.pangram?(sentence)
    sentence.downcase.scan(/[a-z]/).sort.uniq.eql?(CHARACTERS)
  end
end
