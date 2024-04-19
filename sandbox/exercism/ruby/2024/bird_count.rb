# https://exercism.org/tracks/ruby/exercises/bird-count

class BirdCount
  def self.last_week
    new.last_week
  end

  def self.records
    @records ||= [
      [0, 2, 5, 3, 7, 8, 4],
    ]
  end

  def initialize(birds_per_day = [])
    @records = load_records
    @records.push(birds_per_day)
    # TODO The method to write this week's records to self.class.records should be implemented later
  end

  def last_week
    @records[-2]
  end

  def this_week
    @records[-1]
  end

  def yesterday
    this_week[-2]
  end

  def total
    this_week.sum
  end

  def busy_days
    this_week.count { |birds| birds >= 5 }
  end

  def day_without_birds?
    this_week.any?(&:zero?)
  end

  private

  def load_records
    self.class.records.dup
  end
end
