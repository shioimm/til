# https://exercism.org/tracks/ruby/exercises/rna-transcription

class Complement
  DNA_STRANDS = %w[G C T A].freeze
  RNA_STRANDS = %w[C G A U].freeze

  def self.of_dna(sequence)
    sequence.tr(DNA_STRANDS.join, RNA_STRANDS.join)
  end
end
