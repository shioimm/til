require 'fiber'

CONCURRENCY = 4

fibers = CONCURRENCY.times.map do
  Fiber.new do |i|
    puts "#{i + 1}: ID=#{Fiber.current.object_id} / PID=#{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"

    sleep 1
  end
end

fibers.each_with_index do |fiber, i|
  fiber.resume(i)

  puts "#{fiber.object_id} was already terminated - #{Time.now.strftime('%H:%M:%S')}"
end

# $ ruby practices/ruby/concurrency/fiber.rb
#
# 1: ID=60  / PID=67667 - 14:13:02
# 60 was already terminated - 14:13:03
# 2: ID=80  / PID=67667 - 14:13:03
# 80 was already terminated - 14:13:04
# 3: ID=100 / PID=67667 - 14:13:04
# 100 was already terminated - 14:13:05
# 4: ID=120 / PID=67667 - 14:13:05
# 120 was already terminated - 14:13:06
