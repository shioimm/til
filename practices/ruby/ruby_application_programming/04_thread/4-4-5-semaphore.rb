# 引用: Rubyアプリケーションプログラミング P183

require 'thread'

class Semaphore
  def initialize(count)
    @count = count
    @mutex = Mutex.new
    @non_zero_cond = ConditionVariable.new
  end

  def p
    @mutex.synchronize do
      while @count == 0
        @non_zero_cond.wait(@mutex)
      end
      @count -= 1
    end
  end

  def v
    @mutex.synchronize do
      @count += 1
      @non_zero_cond.signal
    end
  end
end

sem = Semaphore.new(5)

Thread.start do
  sem.p

  begin
    puts 'hello'
  ensure
    sem.v
  end
end
