class Future
  def initialize
    @result = nil
    @callbacks = []
  end

  def on_done(&callback)
    @callbacks << callback
  end

  def result=(result)
    @result = result

    @callbacks.each do
      it.call(@result)
    end
  end
end

class EventLoop
  def initialize
    @tasks = []
  end

  def add_coroutine(&block)
    @tasks << [Fiber.new(&block), nil]
  end

  def run
    while !@tasks.empty?
      task, result = @tasks.shift
      next if !task.alive?

      waiting_future = task.resume(result)
      next if !waiting_future.respond_to?(:on_done)

      current_task = task

      waiting_future.on_done do |result|
        # current_task = ひとつめのFiberの続きを@tasksに積み直す
        @tasks << [current_task, result]
      end
    end
  end
end

Burger = Data.define(:name)

puts "Start"
event = EventLoop.new

event.add_coroutine do # ひとつめのFiber
  order = Future.new

  burger = Burger.new("Burger ##{rand(1..10)}")
  puts "#{burger.name} ordered"

  event.add_coroutine do # ふたつめのFiber
    puts "#{burger.name} is being cooked"
    order.result = burger
  end

  result_burger = Fiber.yield(order)
  puts "#{result_burger.name} is ready for pickup!"
  puts "#{result_burger.name} served"
end

event.run
puts "Finish"
