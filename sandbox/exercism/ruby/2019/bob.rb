class Bob
  def self.hey(remark)
    remark = Remark.new(remark)

    return "Calm down, I know what I'm doing!" if remark.yelling? && remark.asking?
    return 'Whoa, chill out!'                  if remark.yelling?
    return 'Sure.'                             if remark.asking?
    return 'Fine. Be that way!'                if remark.speaking_nothing?

    'Whatever.'
  end
end

class Remark
  attr_reader :remark

  def initialize(remark)
    @remark = remark.strip
  end

  def yelling?
    remark.match?(/[A-Z]+/) && remark == remark.upcase
  end

  def asking?
    remark.end_with?('?')
  end

  def speaking_nothing?
    remark.empty?
  end
end
