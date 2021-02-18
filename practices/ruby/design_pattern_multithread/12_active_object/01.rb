# Java言語で学ぶデザインパターン入門 マルチスレッド編 第12章

class MakerClient
  def initialize(name, active_object)
    @name, @active_object = name, active_object
  end

  def run
    # WIP
  end
end

class DisplayClient
  def initialize(name, active_object)
    @name, @active_object = name, active_object
  end

  def run
    # WIP
  end
end

class ActiveObjectFactory
  def self.create_active_object
    servant = Servant.new
    queue = ActivationQueue.new
    scheduler = Scheduler.new(queue)
    proxy = Proxy.new(scheduler, servant)
    scheduler.run
    proxy
  end
end

class Proxy
  def initialize(scheduler, servant)
    @scheduler, @servant = scheduler, servant
  end

  def make_string(count, fillchar)
    # WIP
  end

  def display_string(string)
    # WIP
  end
end

class Scheduler
  def initialize(queue)
    @queue = queue
  end

  def invoke(request)
    # WIP
  end

  def run
    # WIP
  end
end

class ActivationQueue
  MAX_METHOD_REQUEST = 100

  def initialize
    @request_queue = MethodRequest.new(MAX_METHOD_REQUEST)
    @head, @tail, @count = 0, 0, 0
  end

  def put_request(request)
    # WIP
  end

  def take_request
    # WIP
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
    # WIP
  end
end

class DisplayStringRequest
  def initialize(servant, string)
    @servant, @string = servant, string
  end

  def execute
    # WIP
  end
end

class Result
end

class FutureResult
  def set_result(result)
    # WIP
  end

  def get_result_value
    # WIP
  end
end

class RealResult
  def initialize(result_value)
    @result_value = result_value
  end

  def get_result_value
    # WIP
  end
end

class Servant
  def make_string(count, fillchar)
    # WIP
  end

  def display_string(string)
    # WIP
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
