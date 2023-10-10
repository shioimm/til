# Twelve Days from https://exercism.io

class TwelveDays
  GIFTS = [
    { first:    'a Partridge in a Pear Tree' },
    { second:   'two Turtle Doves' },
    { third:    'three French Hens' },
    { fourth:   'four Calling Birds' },
    { fifth:    'five Gold Rings' },
    { sixth:    'six Geese-a-Laying' },
    { seventh:  'seven Swans-a-Swimming' },
    { eighth:   'eight Maids-a-Milking' },
    { ninth:    'nine Ladies Dancing' },
    { tenth:    'ten Lords-a-Leaping' },
    { eleventh: 'eleven Pipers Piping' },
    { twelfth:  'twelve Drummers Drumming' },
  ]

  class << self
    def song
      GIFTS.map.with_index { |gift, index| phrase(index) }.join("\n")
    end

    private

      def day(n)
        GIFTS.flat_map(&:keys)[n].to_s
      end

      def gifts(n)
        GIFTS.flat_map(&:values).take(n + 1).reverse
      end

      def phrase(n)
        "On the #{day n} day of Christmas my true love gave to me: #{gifts_to_phrase_by gifts(n)}.\n"
      end

      def gifts_to_phrase_by(lists)
        *gifts, last_gift = lists
        return last_gift if gifts.empty?

        "#{gifts.join(', ')}, and #{last_gift}"
      end
    end
end

# Enumerable#take
# https://docs.ruby-lang.org/ja/2.6.0/method/Enumerable/i/take.html
