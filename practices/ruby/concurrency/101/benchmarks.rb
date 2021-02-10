require 'benchmark'
require_relative 'fibonacchi'

CONCURRENCY = 4
MAX = 100_000

Benchmark.bmbm do |x|
  x.report("Serial") do
    CONCURRENCY.times do
      solve_fibonacci(MAX)
    end
  end

  x.report("ProcessBased") do
    pids = []

    CONCURRENCY.times do
      pids << fork { solve_fibonacci(MAX) }
    end

    pids.each do |pid|
      Process.waitpid(pid)
    end
  end

  x.report("ThreadBased") do
  end

  x.report("FiberBased") do
  end

  x.report("RactorBased") do
  end
end
