# Java言語で学ぶデザインパターン入門 マルチスレッド編 第7章

class Host
  def initialize
    @helper = Helper.new
  end

  def request(count, c)
    puts "request (#{count} #{c}) BEGIN"

    Thread.new do
      @helper.handle(count, c)
    end

    puts "request (#{count} #{c}) END"
  end
end

class Helper
  def handle(count, c)
    puts "handle (#{count} #{c}) BEGIN"

    count.times do
      slowly
      puts c
    end

    puts " "
    puts "handle (#{count} #{c}) END"
  end

  private

    def slowly
      sleep 0.2
    end
end

puts 'Main BEGIN'

host = Host.new
host.request(10, 'A')
host.request(20, 'B')
host.request(30, 'C')

sleep 10

puts 'Main END'
