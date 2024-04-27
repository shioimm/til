# https://exercism.org/tracks/ruby/exercises/resistor-color-duo

class ResistorColorDuo
  BAND_COLORS = %w[black brown red orange yellow green blue violet grey white]

  def self.value(duo)
    eoncoded_band_colors = BAND_COLORS.map.with_index.to_h
    duo.map(&eoncoded_band_colors)[0..1].join.to_i
  end
end
