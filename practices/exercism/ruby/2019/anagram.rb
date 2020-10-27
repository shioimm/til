# Anagram from https://exercism.io

class Anagram
  def initialize(word)
    @word = word
  end

  def match(list)
    list.select { |sublist| trim(sublist) == trim(word) && !sublist.casecmp?(word) }
  end

  private

    attr_reader :word

    def trim(word)
      word.downcase.chars.sort
    end
end

# String#casecmp?
# https://docs.ruby-lang.org/ja/2.6.0/method/String/i/casecmp=3f.html
