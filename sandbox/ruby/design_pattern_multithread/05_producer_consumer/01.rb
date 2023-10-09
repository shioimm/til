# Java言語で学ぶデザインパターン入門 マルチスレッド編 第5章

class Table
  def initialize(count)
    @tail, @head, @count = 0, 0, 0
    @buffer = Array.new(3)
    @m = Mutex.new
    @cond = ConditionVariable.new
  end

  def put(cake)
    @m.synchronize do
      puts "#{Thread.current.name} puts #{cake}"

      while @count >= @buffer.length
        @cond.wait(@m)
      end

      @buffer[@tail] = cake
      @tail = (@tail + 1) % @buffer.size
      @count += 1
      @cond.broadcast
    end
  end

  def take
    @m.synchronize do
      while @count <= 0
        @cond.wait(@m)
      end

      cake = @buffer[@head]
      @head = (@head + 1) % @buffer.size
      @count -= 1
      @cond.broadcast
      puts "#{Thread.current.name} takes #{cake}"
      cake
    end
  end
end

class Producer
  def initialize(name, table)
    @name, @table = name, table
    @id = 0
    @m = Mutex.new
  end

  def run
    loop do
      sleep rand
      cake = "Cake no. #{next_id} by #{@name}"
      @table.put cake
    end
  end

  private

    def next_id
      @m.synchronize do
        @id += 1
      end
    end
end

class Consumer
  def initialize(name, table)
    @name, @table = name, table
  end

  def run
    loop do
      cake = @table.take
      sleep rand
    end
  end
end

table = Table.new(3)

ps = 3.times.map do |i|
  Thread.new do
    Producer.new("Producer-#{i}", table).run
  end
end

cs = 3.times.map do |i|
  Thread.new do
    Consumer.new("Consumer-#{i}", table).run
  end.join
end

ps.each(&:join)
cs.each(&:join)
