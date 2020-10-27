# Simple Cipher https://exercism.io/

class Cipher
  ALPHABETS     = ('a'..'z').to_a
  MAXIMUM_INDEX = ALPHABETS.size

  attr_reader :key

  def initialize(key = nil)
    raise ArgumentError if key&.empty? || key&.match?(/[^a-z]/)

    @key = key || ALPHABETS.sample(100).join
  end

  def encode(plaintext)
    textalize(plaintext, :+)
  end

  def decode(plaintext)
    textalize(plaintext, :-)
  end

  private

    def textalize(plaintext, operator)
      indexes(plaintext, operator).map { |i| ALPHABETS[i] }.join
    end

    def indexes(plaintext, operator)
      key[0, plaintext.size].chars.map.with_index do |char, i|
        x, y = index_at(plaintext[i]), index_at(char)
        result = x.send(operator, y)

        result >= MAXIMUM_INDEX ? result - MAXIMUM_INDEX : result
      end
    end

    def index_at(char)
      ALPHABETS.index(char)
    end
end
