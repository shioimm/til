# Meetup from https://exercism.io

require 'date'

module Orderale
  refine Array do
    def second
      self[1]
    end

    def third
      self[2]
    end

    def fourth
      self[3]
    end

    def fifth
      self[4]
    end

    def teenth
      # Actually for Meetup
      self.find { |date| (13..19).include? date.day }
    end
  end
end

using Orderale

class Meetup
  def initialize(month, year)
    @month = month
    @year = year
  end

  def day(wday, order)
    days_on(wday).send(order)
  end

  private

    attr_reader :month, :year

    def days_on(wday)
      days_in_a_month.select { |day| day.send("#{wday}?") }
    end

    def days_in_a_month
      Date.new(year, month, 1)..Date.new(year, month, -1)
    end
