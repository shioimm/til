# Phone Number from https://exercism.io

class PhoneNumber
  VALID_NUMBER_REGEX = /^[2-9]\d{2}[2-9]\d{6}$/

  def self.clean(number)
    new(number).clean
  end

  def initialize(number)
    @number = number
  end

  def clean
    VALID_NUMBER_REGEX.match?(formatted_numbers) ? formatted_numbers : nil
  end

  private

    attr_reader :number

    def formatted_numbers
      number.gsub(/[\D|^1]/, '')
    end
end
