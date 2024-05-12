# https://exercism.org/tracks/ruby/exercises/twelve-days

class TwelveDays
  Gift = Data.define(:nth, :gift)

  GIFTS = [
    Gift.new("first", "a Partridge in a Pear Tree"),
    Gift.new("second", "two Turtle Doves"),
    Gift.new("third", "three French Hens"),
    Gift.new("fourth", "four Calling Birds"),
    Gift.new("fifth", "five Gold Rings"),
    Gift.new("sixth", "six Geese-a-Laying"),
    Gift.new("seventh", "seven Swans-a-Swimming"),
    Gift.new("eighth", "eight Maids-a-Milking"),
    Gift.new("ninth", "nine Ladies Dancing"),
    Gift.new("tenth", "ten Lords-a-Leaping"),
    Gift.new("eleventh", "eleven Pipers Piping"),
    Gift.new("twelfth", "twelve Drummers Drumming"),
  ]

  class << self
    def song
      GIFTS.each_with_object({ gifts: [], lyric: [] }) { |g, memo|
        memo[:gifts].unshift(g.gift)
        memo[:gifts].last.insert(0, "and ") if memo[:gifts].size == 2
        memo[:lyric] << "On the #{g.nth} day of Christmas my true love gave to me: #{memo[:gifts].join(', ')}.\n"
      }[:lyric].join("\n")
    end
  end
end
