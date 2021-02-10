require_relative 'fibonacchi'

CONCURRENCY = 4

CONCURRENCY.times do
  solve_fibonacci(100_000)
end
