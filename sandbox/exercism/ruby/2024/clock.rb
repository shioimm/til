# https://exercism.org/tracks/ruby/exercises/clock

class Clock
  attr_reader :hour, :minute

  def initialize(hour: 0, minute: 0)
    @hour, @minute = setup_hour_and_minute(hour, minute)
  end

  def to_s
    "#{hour.to_s.rjust(2, '0')}:#{minute.to_s.rjust(2, '0')}"
  end

  def +(other)
    _hour, _minute = setup_hour_and_minute(hour + other.hour, minute + other.minute)
    Clock.new(hour: _hour, minute: _minute)
  end

  def -(other)
    _hour, _minute = setup_hour_and_minute(hour - other.hour, minute - other.minute)
    Clock.new(hour: _hour, minute: _minute)
  end

  def ==(other)
    self_hour, self_minute = setup_hour_and_minute(hour, minute)
    other_hour, other_minute = setup_hour_and_minute(other.hour, other.minute)
    self_hour.eql?(other_hour) && self_minute.eql?(other_minute)
  end

  alias eql? ==

  private

  def setup_hour_and_minute(hour, minute)
    total_minute = hour * 60 + minute
    _hour, _minute = total_minute.divmod(60)
    [(_hour % 24), _minute]
  end
end
