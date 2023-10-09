# Java言語で学ぶデザインパターン入門 マルチスレッド編 第3章

class Request
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class Queue
  def initialize
    @q = []
    @m = Mutex.new
    @cond = ConditionVariable.new
  end

  def enq(req)
    @m.synchronize do
      @q << req
      @cond.signal
    end

  end

  def deq
    @m.synchronize do
      while @q.empty?
        @cond.wait(@m)
      end

      @q.shift
    end
  end
end

q = Queue.new

client_thread_1 = 10.times.map do |i|
  Thread.new do
    req = Request.new("Request 1: #{i + 1}")
    q.enq(req)
  end
end

client_thread_2 = 10.times.map do |i|
  Thread.new do
    req = Request.new("Request 2: #{i + 1}")
    q.enq(req)
  end
end

server_thread = loop do
  Thread.new do
    p "#{q.deq.name}"
  end
end

[client_thread_1, client_thread_2].each(&:join)
server_thread.join
