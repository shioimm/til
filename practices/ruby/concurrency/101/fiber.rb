require 'fiber'

CONCURRENCY = 4

fibers = CONCURRENCY.times.map do
  Fiber.new do |i|
    puts "#{i + 1}: ObjectID=#{Fiber.current.object_id} / PID=#{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"

    sleep 1
  end
end

fibers.each_with_index do |fiber, i|
  puts "ObjectID=#{fiber.resume(i).object_id} was resumed - #{Time.now.strftime('%H:%M:%S')}"
end

# 1: ObjectID=60  / PID=67667 - 14:13:02
# ObjectID=60 was resumed - 14:13:03
# 2: ObjectID=80  / PID=67667 - 14:13:03
# ObjectID=80 was resumed - 14:13:04
# 3: ObjectID=100 / PID=67667 - 14:13:04
# ObjectID=100 was resumed - 14:13:05
# 4: ObjectID=120 / PID=67667 - 14:13:05
# ObjectID=120 was resumed - 14:13:06
