class Complement
  RNA_TRANSCRIPTION = {
    'C' => 'G',
    'G' => 'C',
    'T' => 'A',
    'A' => 'U'
  }.freeze

  def self.of_dna(rna)
    rna.chars.map(&RNA_TRANSCRIPTION).join || ''
  end
end
