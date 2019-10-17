class Prc
  attr_reader :number
  attr_accessor :necessary, :elapsed

  def initialize(number, necessary, elapsed = 0)
    @number, @necessary, @elapsed = number, necessary, elapsed
  end
end

class Queue
  MAXIMUM = 5

  attr_accessor :container

  def initialize
    @container = []
  end

  def empty?
    container.empty?
  end

  def filled?
    container.size > MAXIMUM
  end

  def enqueue(x)
    raise if filled?

    container.push x
  end

  def dequeue
    raise if empty?

    container.shift
  end
end

processes = [Prc.new('p1', 150),
             Prc.new('p2', 80),
             Prc.new('p3', 200),
             Prc.new('p4', 350),
             Prc.new('p5', 20)]

QUANTUM = 100

queue = Queue.new
processes.each { |process| queue.enqueue process }

pp queue.container

pp '---------------'

loop do
  process = queue.dequeue

  if process.necessary > 0
    process.necessary -= QUANTUM

    if process.necessary.negative?
      process.elapsed += (QUANTUM + process.necessary)
      process.necessary = 0
    else
      process.elapsed += QUANTUM
    end
  end

  queue.enqueue(process)

  break if queue.container.all? { |process| process.necessary.zero? }
end

pp queue.container
