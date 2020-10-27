# Anagram from https://exercism.io↲

class Anagram
  def initialize(detector)
    @detector = detector
  end

  def match(anagrams)
    anagrams.select do |anagram|
      anagram.downcase.chars.sort.eql?(detector.downcase.chars.sort) \
        && anagram.downcase != detector.downcase
    end
  end

  private

    attr_reader :detector
end
