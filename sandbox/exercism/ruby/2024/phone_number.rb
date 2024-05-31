# https://exercism.org/tracks/ruby/exercises/phone-number

class PhoneNumber
  PHONE_NUMBER_REGEX = /^(?<area>[2-9]\d{2})(?<exchange>[2-9]\d{2})(?<subscriber>\d{4})$/

  def self.clean(phone_number)
    phone_number
      .gsub(/[\D|^1]/, '')
      .match(PHONE_NUMBER_REGEX) { |m|
        "#{m[:area]}#{m[:exchange]}#{m[:subscriber]}"
      }
  end
end
