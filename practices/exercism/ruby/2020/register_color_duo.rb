# Resistor Color Duo from https://exercism.io

class ResistorColorDuo
  COLORS = %w[black brown red orange yellow green blue violet grey white].map.with_index.to_h.freeze

  def self.value(duo)
    duo.map(&COLORS).join.to_i
  end
end
