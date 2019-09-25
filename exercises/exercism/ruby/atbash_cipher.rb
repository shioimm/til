# Atbash Cipher from https://exercism.io

class Atbash
  ALPHABETS      = ('a'..'z').to_a
  CHARACTERS     = ALPHABETS.zip(ALPHABETS.reverse).to_h
  MAXIMUM_LENGTH = 5

  def self.encode(plaintext)
    plaintext.downcase
             .scan(/\w/)
             .map { |char| CHARACTERS.fetch(char, char) }
             .each_slice(MAXIMUM_LENGTH)
             .map(&:join)
             .join(' ')
  end

  def self.decode(ciphertext)
    ciphertext.scan(/\w/)
              .map { |char| CHARACTERS.invert.fetch(char, char) }
              .join
  end
end
