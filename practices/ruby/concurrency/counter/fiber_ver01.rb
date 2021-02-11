fiber = Fiber.new do |ex_count|
  loop do
    count = ex_count + 1
    Fiber.yield count
  end
end

10.times do |i|
  File.open('fiber_counter', File::RDWR | File::CREAT) do |f|
    ex_count = f.read.to_i
    count = fiber.resume(ex_count)
    f.rewind
    f.write count
  end
end

puts File.read('fiber_counter').to_i
