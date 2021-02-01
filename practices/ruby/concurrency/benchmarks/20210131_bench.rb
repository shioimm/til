# inspired from https://gist.github.com/ytnk531/edead9655ebdcde7d0273db941ec43ae
# ruby 3.0.0p0 (2020-12-25 revision 95aff21468) [x86_64-darwin18]

CONCURRENCY = 16
Ractor.new {} # for printing warning in advance

def solve_by_inject_to_proc
  (1..1_000_000).inject(&:+)
end

def solve_by_inject_with_block
  (1..1_000_000).inject(0) { |result, n| result + n }
end

def solve_by_each
  x = 0
  (1..1_000_000).each { |y| x += y }
  x
end

require "benchmark"

Benchmark.bmbm do |x|
  x.report("Serial (inject to proc)") do
    CONCURRENCY.times { solve_by_inject_to_proc }
  end

  x.report("Process(inject to proc)") do
    CONCURRENCY.times
               .map { fork { solve_by_inject_to_proc } }
               .each { |pid| Process.waitpid pid }
  end

  x.report("Thread (inject to proc)") do
    CONCURRENCY.times
               .map { Thread.new { solve_by_inject_to_proc } }
               .each(&:join)
  end

  x.report("Ractor (inject to proc)") do
    CONCURRENCY.times
               .map { Ractor.new { solve_by_inject_to_proc } }
               .each(&:take)
  end

  x.report("Serial (inject with block)") do
    CONCURRENCY.times { solve_by_inject_with_block }
  end

  x.report("Process(inject with block)") do
    CONCURRENCY.times
               .map { fork { solve_by_inject_with_block } }
               .each { |pid| Process.waitpid pid }
  end

  x.report("Thread (inject with block)") do
    CONCURRENCY.times
               .map { Thread.new { solve_by_inject_with_block } }
               .each(&:join)
  end

  x.report("Ractor (inject with block)") do
    CONCURRENCY.times
               .map { Ractor.new { solve_by_inject_with_block } }
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

# Rehearsal --------------------------------------------------------------
#
# Serial (inject to proc)      1.455668   0.002359   1.458027 (  1.461714)
# Process(inject to proc)      0.001337   0.006443   2.210275 (  0.302800)
# Thread (inject to proc)      1.462124   0.002492   1.464616 (  1.465054)
# Ractor (inject to proc)      6.441822  23.239916  29.681738 (  3.761091)
#
# Serial (inject with block)   0.994668   0.001197   0.995865 (  0.998099)
# Process(inject with block)   0.001298   0.006131   1.874381 (  0.264270)
# Thread (inject with block)   0.957161   0.002179   0.959340 (  0.959595)
# Ractor (inject with block)   1.864301   0.002881   1.867182 (  0.249867)
#
# Serial (each)                0.689874   0.000553   0.690427 (  0.690993)
# Process(each)                0.001413   0.006451   1.343316 (  0.193792)
# Thread (each)                0.694323   0.001872   0.696195 (  0.696798)
# Ractor (each)                1.339692   0.001939   1.341631 (  0.176860)
#
# ---------------------------------------------------- total: 44.582993sec
#
#                                  user     system      total        real
# Serial (inject to proc)      1.474752   0.000879   1.475631 (  1.477009)
# Process(inject to proc)      0.001255   0.006592   2.227474 (  0.301886)
# Thread (inject to proc)      1.461064   0.002188   1.463252 (  1.463755)
# Ractor (inject to proc)      6.443020  22.213619  28.656639 (  3.680693)
#
# Serial (inject with block)   0.959498   0.000693   0.960191 (  0.961188)
# Process(inject with block)   0.001200   0.006239   1.879823 (  0.256928)
# Thread (inject with block)   0.964735   0.002000   0.966735 (  0.967105)
# Ractor (inject with block)   1.855831   0.002156   1.857987 (  0.243667)
#
# Serial (each)                0.692770   0.000714   0.693484 (  0.694803)
# Process(each)                0.001266   0.006854   1.400307 (  0.189773)
# Thread (each)                0.718576   0.002498   0.721074 (  0.723017)
# Ractor (each)                1.347467   0.001888   1.349355 (  0.177303)
