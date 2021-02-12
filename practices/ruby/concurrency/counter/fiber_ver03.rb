fiber = Fiber.new do |initial|
  count = initial + 1

  loop do
    Fiber.yield count
    count += 1
  end
end

10.times do |i|
  File.open('fiber_counter', File::RDWR | File::CREAT) do |f|
    initial = f.read.to_i
    count = fiber.resume(initial)
    f.rewind
    f.write count
  end
end

puts File.read('fiber_counter').to_i
