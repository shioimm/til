class FiberWrapper
  def fiber
    Fiber.new do
      loop do
        File.open('fiber_counter', File::RDWR | File::CREAT) do |f|
          ex_count = f.read.to_i
          count = ex_count + 1
          f.rewind
          f.write count
        end

        Fiber.yield
      end
    end
  end

  def resume
    fiber.resume
  end
end

ts = 10.times.map do
  Thread.fork do
    FiberWrapper.new.resume
  end
end

ts.each(&:join)

puts File.read('fiber_counter').to_i
