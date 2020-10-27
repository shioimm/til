# Isogram from https://exercism.io/

class Isogram
  def self.isogram?(input)
    new(input).isogram?
  end

  def initialize(input)
    @input = input
  end

  def isogram?
    string.size == string.uniq.size
  end

  private

    attr_reader :input

    def string
      input.downcase.scan(/[a-z]/)
    end
end
