# Crypto Square from https://exercism.io

class Crypto
  def initialize(plaintext)
    @plaintext = plaintext
  end

  def ciphertext
    return plaintext if size.zero?

    letters.each_slice(size)
           .map { |line| (size - line.size).times { line << ' ' }.then { line } }
           .transpose
           .map(&:join)
           .join(' ')
  end

  private

    attr_reader :plaintext

    def letters
      plaintext.downcase.scan(/\w/)
    end

    def size
      Math.sqrt(letters.size).ceil
    end
end
