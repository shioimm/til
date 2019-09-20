# Wordy from https://exercism.io

class WordProblem
  OPERATORS = {
    'plus'       => '+',
    'minus'      => '-',
    'multiplied' => '*',
    'divided'    => '/'
  }.freeze

  def initialize(sentence)
    @sentence = sentence
  end

  def answer
    raise ArgumentError if invalid?

    @answer ||= numbers.inject { |sum, n| sum.send(operators.shift, n) }
  end

  private

    attr_reader :sentence

    def numbers
      @numbers ||= sentence.scan(/-?\d+/).map(&:to_i)
    end

    def operators
      @operators ||= sentence.split(' ').map(&OPERATORS).compact
    end

    def invalid?
      @validation ||= operators.empty?
    end
end
