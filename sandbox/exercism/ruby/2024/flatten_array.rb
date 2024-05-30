# https://exercism.org/tracks/ruby/exercises/flatten-array

class FlattenArray
  class << self
    def flatten(input)
      flatten_values([], input)
    end

    def flatten_values(result, input)
      input.each do |value|
        if value.is_a? Array
          flatten_values(result, value)
        elsif value.nil?
          # Do nothing
        else
          result << value
        end
      end

      result
    end
  end
end
