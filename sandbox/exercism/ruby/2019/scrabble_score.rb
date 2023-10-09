# Scrabble Score from https://exercism.io

class Scrabble
  LETTERS = {
    1  => %w[A E I O U L N R S T],
    2  => %w[D G],
    3  => %w[B C M P],
    4  => %w[F H V W Y],
    5  => %w[K],
    8  => %w[J X],
    10 => %w[Q Z]
  }.freeze

  def self.score(string)
    new(string).score
  end

  def initialize(string)
    @string = string
  end

  def score
    string.to_s.strip.upcase.chars.map(&scores).sum
  end

  private

    attr_reader :string

    def scores
      LETTERS.flat_map { |k, v| v.product([k]) }.to_h
    end
end

# Enumerable#collect_concat(flat_map -> Enumerator)
# https://docs.ruby-lang.org/ja/2.6.0/method/Enumerable/i/collect_concat.html
# Enumerable#each_slice
# https://docs.ruby-lang.org/ja/latest/method/Enumerable/i/each_slice.html
