class EventLoop
  def initialize
    @tasks = []
  end

  def add_coroutine(*args, &task)
    @tasks << Fiber.new { task.call(*args) }
  end

  def run
    while !@tasks.empty?
      task = @tasks.shift

      if task.alive?
        puts "[PARENT] Resume task #{task}"
        task.resume(1)
        @tasks << task if task.alive?
      end

       puts "[PARENT] All tasks completed" if !task.alive?
    end
  end
end

def add_one(n, prefix)
  n.times do
    puts "[CHILD: #{prefix}] Yield: #{it}"
    result = Fiber.yield
    puts "[CHILD: #{prefix}] Resumed: result = #{it + result}"
  end
end

puts "Start"
event = EventLoop.new

event.add_coroutine(2, "foo") do |n, prefix|
  add_one(n, prefix)
end

event.add_coroutine(3, "bar") do |n, prefix|
  add_one(n, prefix)
end

event.run
puts "Finish"
