# https://exercism.org/tracks/ruby/exercises/isogram

class Isogram
  def self.isogram?(input)
    chars = input.downcase.scan(/\w/)
    chars.size == chars.uniq.size
  end
end
