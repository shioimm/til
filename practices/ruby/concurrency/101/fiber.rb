require 'fiber'
require_relative 'fibonacchi'

fiber = Fiber.new do
  loop do
    Fiber.yield solve_fibonacci(100_000)
  end
end

4.times do
  fiber.resume
end
