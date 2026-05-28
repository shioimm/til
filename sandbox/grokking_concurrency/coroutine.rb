class EventLoop
  def initialize
    @tasks = []
  end

  def add_coroutine(task)
    @tasks << task
  end

  def run
    while !@tasks.empty?
      task = @tasks.shift

      if task.alive?
        puts "[PARENT] Resume task #{task}"
        task.resume(1)
        add_coroutine(task) if task.alive?
      end

       puts "[PARENT] All tasks completed" if !task.alive?
    end
  end
end

def add_one(n, prefix)
  Fiber.new do
    n.times do
      puts "[CHILD: #{prefix}] Yield: #{it}"
      result = Fiber.yield
      puts "[CHILD: #{prefix}] Resumed: result = #{it + result}"
    end
  end
end

puts "Start"
event = EventLoop.new
event.add_coroutine(add_one(2, "foo"))
event.add_coroutine(add_one(3, "bar"))
event.run
puts "Finish"
