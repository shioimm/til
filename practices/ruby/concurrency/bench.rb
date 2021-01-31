# inspired from https://gist.github.com/ytnk531/edead9655ebdcde7d0273db941ec43ae

CONCURRENCY = 4

def solve_by_inject
  (1..1_000_000).inject(&:+)
end

def solve_by_each
  x = 0
  (1..1_000_000).each { |y| x += y }
end

require "benchmark"

Benchmark.bmbm do |x|
  x.report("Serial (inject)") do
    CONCURRENCY.times { solve_by_inject }
  end

  x.report("Process(inject)") do
    CONCURRENCY.times
               .map { fork { solve_by_inject } }
               .each { |pid| Process.waitpid pid }
  end

  x.report("Thread (inject)") do
    CONCURRENCY.times
               .map { Thread.new { solve_by_inject } }
               .each(&:join)
  end

  x.report("Ractor (inject)") do
    CONCURRENCY.times
               .map { Ractor.new { solve_by_inject } }
               .each(&:take)
  end

  x.report("Serial (each)") do
    CONCURRENCY.times { solve_by_each }
  end

  x.report("Process(each)") do
    CONCURRENCY.times
               .map { fork { solve_by_each } }
               .each { |pid| Process.waitpid pid }
  end

  x.report("Thread (each)") do
    CONCURRENCY.times
               .map { Thread.new { solve_by_each } }
               .each(&:join)
  end

  x.report("Ractor (each)") do
    CONCURRENCY.times
               .map { Ractor.new { solve_by_each } }
               .each(&:take)
  end
end

# Rehearsal ---------------------------------------------------
#
# Serial (inject)   0.296405   0.001951   0.298356 (  0.300974)
# Process(inject)   0.000409   0.002015   0.326770 (  0.083655)
# Thread (inject)   0.278962   0.001175   0.280137 (  0.281028)
# Ractor (inject)   1.000066   1.629764   2.629830 (  0.818559)
#
# Serial (each)     0.183466   0.000550   0.184016 (  0.184467)
# Process(each)     0.000432   0.001921   0.215049 (  0.058321)
# Thread (each)     0.175191   0.000795   0.175986 (  0.176319)
# Ractor (each)     0.189250   0.000812   0.190062 (  0.049992)
#
# ------------------------------------------ total: 4.300206sec
#
#                       user     system      total        real
# Serial (inject)   0.385640   0.000743   0.386383 (  0.387367)
# Process(inject)   0.000390   0.002063   0.324026 (  0.084583)
# Thread (inject)   0.382129   0.000894   0.383023 (  0.383885)
# Ractor (inject)   1.029953   1.611092   2.641045 (  0.822547)
#
# Serial (each)     0.182145   0.000354   0.182499 (  0.183222)
# Process(each)     0.000332   0.001949   0.213792 (  0.056231)
# Thread (each)     0.173701   0.000830   0.174531 (  0.175032)
# Ractor (each)     0.194265   0.000489   0.194754 (  0.049976)
