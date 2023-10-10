# Transpose from https://exercism.io

class Transpose
  def self.transpose(input)
    new(input).transpose
  end

  def initialize(input)
    @input = input
  end

  def transpose
    transposed_lines.map.with_index do |chars, i|
      if chars.end_with?(' ')
        chars[0, maximum_length(transposed_lines[i..-1].map(&:rstrip))]
      else
        chars
      end
    end.join("\n").rstrip
  end

  private

    attr_reader :input

    def transposed_lines
      lines.map { |line| line.ljust(maximum_length(lines), ' ') }
           .map(&:chars)
           .transpose
           .map(&:join)
    end

    def lines
      input.lines(chomp: true)
    end

    def maximum_length(lines)
      lines.map(&:size).max
    end
end
