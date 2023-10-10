# Java言語で学ぶデザインパターン入門 マルチスレッド編 第11章

class Log
  def initialize
    @file = nil
  end

  def print(s)
    @file = File.open('log.txt', "a")
    @file.write "#{s}\n"
  end

  def close
    @file.write "= End of log =\n"
    @file.close
  end
end

puts "Begin"

log = Log.new

10.times do |i|
  log.print "main: i = #{i}"

  sleep 0.1
end

log.close

puts "End"
