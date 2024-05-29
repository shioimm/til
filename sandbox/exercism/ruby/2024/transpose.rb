# https://exercism.org/tracks/ruby/exercises/transpose

class Transpose
  def self.transpose(input)
    self.new(input).transpose
  end

  def initialize(input)
    @lines = input.lines(chomp: true)
  end

  def transpose
    transposes_lines.map.with_index { |line, i|
      line.end_with?(' ') ? line[0, line_width(i)] : line
    }.join("\n").rstrip
  end

  private

  def transposes_lines
    @transposes_lines ||= @lines.map { |line| line.ljust(@lines.map(&:size).max, ' ').chars }.transpose.map(&:join)
  end

  def line_width(lineno)
    transposes_lines[lineno..-1].map { |line| line.rstrip.size }.max
  end
end
