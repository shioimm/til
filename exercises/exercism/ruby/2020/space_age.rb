# Space Age from https://exercism.io

class SpaceAge
  SECONDS_PER_YEAR_ON_EARTH = 31557600

  ORBITAL_PERIODS = {
    earth: 1,
    mercury: 0.2408467,
    venus: 0.61519726,
    mars: 1.8808158,
    jupiter: 11.862615,
    saturn: 29.447498,
    uranus: 84.016846,
    neptune: 164.79132
  }.freeze

  def initialize(second)
    @second = second
  end

  ORBITAL_PERIODS.each do |planet, orbital_period|
    define_method("on_#{planet}") do
      second.to_f / (SECONDS_PER_YEAR_ON_EARTH * orbital_period)
    end
  end

  private

    attr_reader :second
end
