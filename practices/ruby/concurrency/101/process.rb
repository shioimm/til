require_relative 'fibonacchi'

CONCURRENCY = 4

pids = []

CONCURRENCY.times do
  pids << fork { solve_fibonacci(100_000) }
end

pids.each do |pid|
  Process.waitpid(pid)
end
