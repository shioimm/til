require_relative 'fibonacchi'

CONCURRENCY = 4

threads = []

CONCURRENCY.times do
  threads << Thread.new { solve_fibonacci(100_000) }
end

threads.each(&:join)
