# https://exercism.org/tracks/ruby/exercises/space-age

class SpaceAge
  OrbitalPeriod = Data.define(:planet, :period)

  SECONDS_PER_YEAR_ON_EARTH = 31557600
  ORBITAL_PERIODS = [
    OrbitalPeriod.new(:earth,   SECONDS_PER_YEAR_ON_EARTH),
    OrbitalPeriod.new(:mercury, SECONDS_PER_YEAR_ON_EARTH *   0.2408467),
    OrbitalPeriod.new(:venus,   SECONDS_PER_YEAR_ON_EARTH *   0.61519726),
    OrbitalPeriod.new(:mars,    SECONDS_PER_YEAR_ON_EARTH *   1.8808158),
    OrbitalPeriod.new(:jupiter, SECONDS_PER_YEAR_ON_EARTH *  11.862615),
    OrbitalPeriod.new(:saturn,  SECONDS_PER_YEAR_ON_EARTH *  29.447498),
    OrbitalPeriod.new(:uranus,  SECONDS_PER_YEAR_ON_EARTH *  84.016846),
    OrbitalPeriod.new(:neptune, SECONDS_PER_YEAR_ON_EARTH * 164.79132),
  ].freeze

  def initialize(seconds)
    @seconds = seconds.to_f
  end

  ORBITAL_PERIODS.each do |op|
    define_method("on_#{op.planet}") { @seconds / op.period }
  end
end
