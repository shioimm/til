# 引用: Rubyアプリケーションプログラミング P179

require 'thread'
require 'monitor'

class Queue
  def initialize
    @que = []
    @monitor = Monitor.new
    @not_empty_cond = @monitor.new_cond
  end

  def enq(obj)
    @monitor.synchronize do
      @que.push(obj)
      @not_empty_cond.signal
    end
  end

  def deq
    @monitor.synchronize do
      while @que.empty?
        @not_empty_cond.wait(@mutex)
      end
      return @que.shift
    end
  end
end

class SizedQueue < Queue
  attr_reader :max

  def initialize(max)
    @max = max
    @not_empty_cond = @monitor.new_cond
  end

  def enq(obj)
    @monitor.synchronize do
      while @que.length >= @max
        @not_empty_cond.wait(@mutex)
      end
      super(obj)
    end
  end

  def deq
    @monitor.synchronize do
      obj = super
      if @que.length < @max
        @not_empty_cond.signal
      end
      return obj
    end
  end

  def max=(max)
    @monitor.synchronize do
      @max = max
      @not_empty_cond.broadcast
    end
  end
end
