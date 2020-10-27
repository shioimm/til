# Affine Cipher from https://exercism.io

class Affine
  ALPHABETS = ('a'..'z').to_a
  DIVISOR   = ALPHABETS.size

  def initialize(a, b)
    @a, @b = a, b

    raise ArgumentError if not_coprime?
  end

  def encode(plaintext)
    init(plaintext).downcase
                   .tr('a-z', encrypted_alphabets)
                   .scan(/\w{1,5}/)
                   .join(' ')
  end

  def decode(ciphertext)
    init(ciphertext).tr(encrypted_alphabets, 'a-z')
  end

  private

    attr_reader :a, :b

    def encrypted_alphabets
      ALPHABETS.map.with_index { |_, i| encrypt(i) }.join
    end

    def encrypt(index)
      ALPHABETS[(a * index + b).modulo DIVISOR ]
    end

    def init(text)
      text.gsub(/[^\w]/, '')
    end

    def not_coprime?
      (2..a).any? { |n| a.modulo(n).zero? && DIVISOR.modulo(n).zero? }
    end
end

# String#tr
# https://docs.ruby-lang.org/ja/2.6.0/method/String/i/tr.html
