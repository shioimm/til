# https://exercism.org/tracks/ruby/exercises/scrabble-score

class Scrabble
  LETTERS = {
    %w[A E I O U L N R S T] => 1,
    %w[D G]                 => 2,
    %w[B C M P]             => 3,
    %w[F H V W Y]           => 4,
    %w[K]                   => 5,
    %w[J X]                 => 8,
    %w[Q Z]                 => 10,
  }

  def initialize(letters)
    @chars = letters.upcase.chars
  end

  def score
    @chars.sum(&letters)
  end

  private

  def letters
    @letters ||= LETTERS.flat_map { |l, v| l.product(Array(v)) }.to_h
  end
end
