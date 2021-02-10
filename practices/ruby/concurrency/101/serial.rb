require_relative 'fibonacchi'

CONCURRENCY = 12

CONCURRENCY.times do |i|
  solve_fibonacci(100_000)
end
