require 'fiber'

@queue = []

Fiber.new do
  10.times do
    File.open('fiber_counter', File::RDWR | File::CREAT) do |f|
      ex_count = f.read.to_i
      count = ex_count + 1
      @queue << [count, Fiber.current]
    end

    Fiber.yield
  end
end.resume

Fiber.new do
  10.times do
    count, fiber = @queue.shift

    File.open('fiber_counter', File::RDWR | File::CREAT) do |f|
      f.rewind
      f.write count
    end

    fiber.resume
  end
end.resume

puts File.read('fiber_counter').to_i
