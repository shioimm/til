# Word Count from https://exercism.io

class Phrase
  def initialize(phrase)
    @phrase = phrase
  end

  def word_count
    phrase.downcase
          .scan(/\b[\w']+\b/)
          .group_by(&:itself)
          .transform_values(&:size)
  end

  private

    attr_reader :phrase
end

# Object#itself
# https://docs.ruby-lang.org/ja/2.6.0/method/Object/i/itself.html
# Hash#transform_values
# https://docs.ruby-lang.org/ja/2.6.0/method/Hash/i/transform_values.html
