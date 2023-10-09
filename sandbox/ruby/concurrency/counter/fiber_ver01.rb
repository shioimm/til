fibers = 10.times.map do
  Fiber.new do
    File.open('fiber_counter', File::RDWR | File::CREAT) do |f|
      ex_count = f.read.to_i
      count = ex_count + 1
      f.rewind
      f.write count
    end
  end
end

fibers.each(&:resume)

puts File.read('fiber_counter').to_i
