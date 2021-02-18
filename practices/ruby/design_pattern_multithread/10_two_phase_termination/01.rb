# Java言語で学ぶデザインパターン入門 マルチスレッド編 第10章

class CountUp
  def initialize
    @counter = 0
    @shutdown_requested = false
  end

  def shutdown_request
    @shutdown_requested = true
    Thread.exit
  end

  def run
    begin
      while !@shutdown_requested
        work
      end
    ensure
      shutdown
    end
  end

  private

    def work
      @counter += 1
      puts "work: counter #{@counter}"
      sleep 0.5
    end

    def shutdown
      puts "shutdown: counter #{@counter}"
    end
end

countup = CountUp.new

t1 = Thread.new do
  countup.run
end

sleep 1

t2 = Thread.new do
  countup.shutdown_request
end

puts "main Join"

[t1, t2].each(&:join)

puts "main End"
