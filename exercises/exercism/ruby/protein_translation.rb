# Protein Translation from https://exercism.io

class InvalidCodonError < StandardError; end

class Translation
  TRANSLATOR = {
    'Methionine'    => %w[AUG],
    'Phenylalanine' => %w[UUU UUC],
    'Leucine'       => %w[UUA UUG],
    'Serine'        => %w[UCU UCC UCA UCG],
    'Tyrosine'      => %w[UAU UAC],
    'Cysteine'      => %w[UGU UGC],
    'Tryptophan'    => %w[UGG],
    'STOP'          => %w[UAA UAG UGA]
  }.flat_map { |k, v| v.product([k]) }.to_h

  def self.of_codon(codon)
    TRANSLATOR[codon]
  end

  def self.of_rna(strands)
    strands.scan(/\w{3}/)
           .map { |strand| TRANSLATOR[strand] || raise(InvalidCodonError) }
           .take_while { |strand| strand != 'STOP' }
  end
end

# Enumerable#take_while
# https://docs.ruby-lang.org/ja/2.6.0/method/Enumerable/i/take_while.html
