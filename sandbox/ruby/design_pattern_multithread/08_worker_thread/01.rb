# Java言語で学ぶデザインパターン入門 マルチスレッド編 第8章

class Client
  def initialize(name, channel)
    @name, @channel = name, channel
  end

  def run
    for i in 0.. do
      request = Request.new(@name, i)
      @channel.put_request(request)
      sleep rand
    end
  end
end

class Request
  def initialize(name, number)
    @name, @number = name, number
  end

  def execute
    puts "#{Thread.current.name} executes #{self.to_str}"
    sleep rand
  end

  def to_str
    "[ Request from #{@name} No. #{@number}]"
  end
end

class Channel
  MAX_REQUEST = 100

  def initialize(threads)
    @queue = Array.new(MAX_REQUEST)
    @head, @tail, @count = 0, 0, 0
    @m = Mutex.new
    @cond = ConditionVariable.new
    @thread_pool = 5.times.map do |i|
      Worker.new("Worker - #{i}", self)
    end
  end

  def start_works
    @thread_pool.each(&:run)
  end

  def put_request(request)
    @m.synchronize do
      while @count >= @queue.size
        @cond.wait(@m)
      end

      @queue[@tail] = request
      @tail = (@tail + 1) % @queue.size
      @count += 1
      @cond.broadcast
    end
  end

  def take_request
    @m.synchronize do
      while @count <= 0
        @cond.wait(@m)
      end

      request = @queue[@head]
      @head = (@head + 1) % @queue.size
      @count -= 1
      @cond.broadcast
      request
    end
  end
end

class Worker
  def initialize(name, channel)
    @name, @channel = name, channel
  end

  def run
    loop do
      request = @channel.take_request
      request.execute
    end
  end
end

channel = Channel.new(5)

cs = 3.times.map do |i|
  Thread.new do
    Thread.current.name = "Thread #{i}"
    Client.new("Thread #{i}", channel).run
  end
end

channel.start_works
cs.each(&:join)
