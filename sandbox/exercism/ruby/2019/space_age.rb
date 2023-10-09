# Space Age from https://exercism.io

class SpaceAge
  SECONDS_PER_YEAR_ON_EARTH   = 31557600
  SECONDS_PER_YEAR_ON_PLANETS = {
    earth:   SECONDS_PER_YEAR_ON_EARTH,
    mercury: SECONDS_PER_YEAR_ON_EARTH * 0.2408467,
    venus:   SECONDS_PER_YEAR_ON_EARTH * 0.61519726,
    mars:    SECONDS_PER_YEAR_ON_EARTH * 1.8808158,
    jupiter: SECONDS_PER_YEAR_ON_EARTH * 11.862615,
    saturn:  SECONDS_PER_YEAR_ON_EARTH * 29.447498,
    uranus:  SECONDS_PER_YEAR_ON_EARTH * 84.016846,
    neptune: SECONDS_PER_YEAR_ON_EARTH * 164.79132,
  }.freeze

  def initialize(seconds)
    @seconds = seconds.to_f
  end

  SECONDS_PER_YEAR_ON_PLANETS.each do |planet, seconds_per_year|
    define_method("on_#{planet}") { seconds / seconds_per_year }
  end

  private

    attr_reader :seconds
end

# Module#define_method
# https://docs.ruby-lang.org/ja/2.6.0/method/Module/i/define_method.html
