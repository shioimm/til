# Clock from https://exercism.io

class Clock
  MINUTES_OF_HOUR = 60
  MINUTES_OF_DAY  = 24 * 60

  def initialize(hour: 0, minute: 0)
    @minutes = hour * MINUTES_OF_HOUR + minute
  end

  def to_s
    "#{hour}:#{minute}"
  end

  def +(other)
    Clock.new(minute: minutes + other.minutes)
  end

  def -(other)
    Clock.new(minute: minutes - other.minutes)
  end

  def ==(other)
    Clock.new(minute: minutes).to_s == Clock.new(minute: other.minutes).to_s
  end

  protected

    attr_reader :minutes

  private

    def hour
      "#{minutes % MINUTES_OF_DAY / MINUTES_OF_HOUR}".rjust(2, '0')
    end

    def minute
      "#{minutes % MINUTES_OF_HOUR}".rjust(2, '0')
    end
end
