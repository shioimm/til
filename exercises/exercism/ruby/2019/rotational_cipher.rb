# Rotational Cipher from https://exercism.io

class RotationalCipher
  UPCASES   = ('A'..'Z').to_a
  DOWNCASES = ('a'..'z').to_a

  class << self
    def rotate(plaintext, key)
      plaintext.chars.map do |char|
        if char.match?(/[A-Z]/)
          convert_character(UPCASES, key, char)
        elsif char.match?(/[a-z]/)
          convert_character(DOWNCASES, key, char)
        else
          char
        end
      end.join
    end

    private

      def convert_character(letters, key, char)
        letters.rotate(key)[letters.index(char)]
      end
  end
end
