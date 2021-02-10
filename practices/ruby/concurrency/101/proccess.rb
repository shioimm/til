require_relative 'fibonacchi'

CONCURRENCY = 12

pids = []

CONCURRENCY.times do |i|
  pids << fork { solve_fibonacci(100_000) }
end

pids.each do |pid|
  Process.waitpid(pid)
end
