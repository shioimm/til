require 'benchmark'

Benchmark.bmbm do |x|
  x.report("Serial") do
  end

  x.report("ProcessBased") do
  end

  x.report("ThreadBased") do
  end

  x.report("FiberBased") do
  end

  x.report("RactorBased") do
  end
end
