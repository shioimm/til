require 'benchmark'
require_relative 'fibonacchi'

CONCURRENCY = 4
MAX = 10_000

Benchmark.bm do |x|
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
    threads = []

    CONCURRENCY.times do
      threads << Thread.new { solve_fibonacci(MAX) }
    end

    threads.each(&:join)
  end

  x.report("FiberBased") do
    fiber = Fiber.new do
      loop do
        Fiber.yield solve_fibonacci(MAX)
      end
    end

    CONCURRENCY.times do
      fiber.resume
    end
  end

  x.report("RactorBased") do
    ractors = []

    pipe = Ractor.new do
      loop do
        Ractor.yield solve_fibonacci(10_000)
      end
    end

    CONCURRENCY.times do
      ractors << Ractor.new(pipe) do |pipe|
        pipe.take
      end
    end

    ractors.each(&:take)
  end
end
