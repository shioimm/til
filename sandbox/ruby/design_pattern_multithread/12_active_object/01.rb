# Java言語で学ぶデザインパターン入門 マルチスレッド編 第12章

class MakerClient
  def initialize(name, active_object)
    @name, @active_object = name, active_object
    @fillchar = @name[0]
  end

  def run
    for i in 1.. do
      result = @active_object.make_string(i, @fillchar)
      sleep 1
      value = request.get_result_value
      puts "value = #{value}"
    end
  end
end

class DisplayClient
  def initialize(name, active_object)
    @name, @active_object = name, active_object
  end

  def run
    for i in 1.. do
      @active_object.display_string(i)
      sleep 2
    end
  end
end

class ActiveObjectFactory
  def self.create_active_object
    servant = Servant.new # 実際の処理を行う
    queue = ActivationQueue.new # MethodRequestオブジェクトを順序よく保持する
    scheduler = Scheduler.new(queue) # MethodRequestオブジェクトをexecuteする
    proxy = Proxy.new(scheduler, servant) # メソッド呼び出しをMethodRequestオブジェクトに変換する
    scheduler.run
    proxy
  end
end

class Proxy
  def initialize(scheduler, servant)
    @scheduler, @servant = scheduler, servant
  end

  def make_string(count, fillchar)
    future = FutureResult.new
    @scheduler.invoke(MakeStringRequest.new(@servant, future, count, fillchar))
    future
  end

  def display_string(string)
    @scheduler.invoke(DisplayStringRequest.new(@servant, string))
  end
end

class Scheduler
  def initialize(queue)
    @queue = queue
  end

  def invoke(request)
    @queue.put_request(request)
  end

  def run
    request = @queue.take_request
    request.execute
  end
end

class ActivationQueue
  def initialize
    @request_queue = MethodRequest.new()
    @head, @tail, @count = 0, 0, 0
    @m = Mutex.new
    @cond = ConditionVariable.new
  end

  def put_request(request)
    @m.synchronize do
      while @count >= @request_queue.size
        @cond.wait @m
      end

      @request_queue[@tail] = request
      @tail = (@tail + 1) % @request_queue.size
      @count += 1
      @cond.broadcast
    end
  end

  def take_request
    @m.synchronize do
      while @count <= 0
        @cond.wait @m
      end

      request = @request_queue[head]
      @head = (@head + 1) % @request_queue.size
      @count -= 1
      @cond.broadcast
      request
    end
  end
end

class MethodRequest
  def initialize(servant, future)
    @servant, @future = servant, future
  end
end

class MakeStringRequest
  def initialize(servant, future, count, fillchar)
    @servant, @future, @count, @fillchar = servant, future, count, fillchar
  end

  def execute
    result = @servant.make_string(@count, @fillchar)
    @future.set_result(result)
  end
end

class DisplayStringRequest
  def initialize(servant, string)
    @servant, @string = servant, string
  end

  def execute
    @servant.display_string(@string)
  end
end

class Result
end

class FutureResult
  def initialize
    @result = nil
    @ready = false
    @m = Mutex.new
    @cond = ConditionVariable.new
  end

  def set_result(result)
    @m.synchronize do
      @result = result
      @ready = true
      @cond.broadcast
    end
  end

  def get_result_value
    @m.synchronize do
      while !ready
        @cond.wait @m
      end

      @result.get_result_value
    end
  end
end

class RealResult
  def initialize(result_value)
    @result_value = result_value
  end

  def get_result_value
    @result_value
  end
end

class Servant
  def make_string(count, fillchar)
    str = count.times.each_with_object([]) do |i, arr|
      arr << fillchar
      sleep 1
    end

    RealResult.new(str)
  end

  def display_string(string)
    puts "display_string #{string}"
    sleep 1
  end
end

# Main
active_object = ActiveObjectFactory.create_active_object

t1 = Thread.new do
  MakerClient.new("Alice", active_object).run
end

t2 = Thread.new do
  MakerClient.new("Bobby", active_object).run
end

t3 = Thread.new do
  DisplayClient.new("Chris", active_object).run
end

[t1, t2, t3].each(&:join)
