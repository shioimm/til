# Java言語で学ぶデザインパターン入門 マルチスレッド編 第9章

class Host
  def request(count, c)
    puts "request (#{count} #{c}) BEGIN"

    future = FutureData.new

    Thread.new do
      read_data = RealData.new(count, c)
      future.set_real_data(read_data)
    end

    puts "request (#{count} #{c}) END"

    future
  end
end

class FutureData
  def initialize
    @m = Mutex.new
    @cond = ConditionVariable.new
    @read_data = nil
    @ready = false
  end

  def set_real_data(read_data)
    return if @ready

    @m.synchronize do
      @read_data = read_data
      @ready = true
      @cond.broadcast
    end
  end

  def get_content
    @m.synchronize do
      while !@ready
        @cond.wait(@m)
      end

      @read_data.get_content
    end
  end
end

class RealData
  def initialize(count, c)
    @count, @c = count, c
    puts "making RealData (#{count} #{c}) BEGIN"

    @content = count.times.map do ||
      sleep 0.1
      c
    end.join

    puts "making RealData (#{count} #{c}) END"
  end

  def get_content
    @content
  end
end

puts 'Main BEGIN'

host = Host.new
d1 = host.request(10, 'A')
d2 = host.request(20, 'B')
d3 = host.request(30, 'C')

puts 'Main other job BEGIN'

sleep 5

puts 'Main other job END'

puts "data 1 - #{d1.get_content}"
puts "data 2 - #{d2.get_content}"
puts "data 3 - #{d3.get_content}"

puts 'Main END'
