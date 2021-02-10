require_relative 'fibonacchi'

CONCURRENCY = 4

ractors = []

pipe = Ractor.new do
  loop do
    Ractor.yield solve_fibonacci(100_000)
  end
end

CONCURRENCY.times do
  ractors << Ractor.new(pipe) do |pipe|
    pipe.take
  end
end

ractors.each(&:take)
