# https://exercism.org/tracks/ruby/exercises/assembly-line

class AssemblyLine
  PRODUCTION_OUTPUT_PER_HOUR = 221

  def self.success_rate(speed)
    case speed
    when (1..4)   then 1.0
    when (5..8)   then 0.9
    when (9..9)   then 0.8
    when (10..10) then 0.77
    end
  end

  def initialize(speed)
    @speed = speed
  end

  def production_rate_per_hour
    PRODUCTION_OUTPUT_PER_HOUR * @speed * self.class.success_rate(@speed)
  end

  def working_items_per_minute
    (production_rate_per_hour / 60).floor
  end
end
