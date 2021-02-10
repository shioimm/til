require 'benchmark'

CONCURRENCY = 4
MAX = 100_000

Benchmark.bmbm do |x|
  x.report("Serial") do
    CONCURRENCY.times do
      sleep 1
    end
  end

  x.report("ProcessBased") do
    pids = []

    CONCURRENCY.times do
      pids << fork { sleep 1 }
    end

    pids.each do |pid|
      Process.waitpid(pid)
    end
  end

  x.report("ThreadBased") do
    threads = []

    CONCURRENCY.times do
      threads << Thread.new { sleep 1 }
    end

    threads.each(&:join)
  end

  x.report("FiberBased") do
    fiber = Fiber.new do
      loop do
        Fiber.yield sleep 1
      end
    end

    CONCURRENCY.times do
      fiber.resume
    end
  end

  x.report("RactorBased") do
    ractors = []

    CONCURRENCY.times do
      ractors << Ractor.new do
        sleep 1
      end
    end

    ractors.each(&:take)
  end
end
