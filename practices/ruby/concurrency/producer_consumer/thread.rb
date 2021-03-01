class Factory
  def initialize(size)
    @line     = SizedQueue.new(size)
    @max_size = size # 同時に作ることができる最大数
    @mutex    = Mutex.new
    @cond     = ConditionVariable.new
  end

  def make(product)
    @mutex.synchronize do
      while @line.size >= @max_size # 最大仕掛かり数 >= 同時に作ることができる最大数
        @cond.wait(@mutex)
      end

      @line.push product
      puts "#{Thread.current.name} makes #{product}. Line: #{@line.size}/#{@max_size}"
      @cond.signal
    end
  end

  def take
    @mutex.synchronize do
      while @line.size <= 0 # @line.size = 最大仕掛かり数 <= 0
        @cond.wait(@mutex)
      end

      product = @line.pop
      @cond.signal
      puts "#{Thread.current.name} takes #{product}. Line: #{@line.size}/#{@max_size}"
      product
    end
  end
end

class Producer
  @@product_no = 1

  def initialize(name, factory)
    Thread.current.name = name
    @factory = factory
    @mutex   = Mutex.new
  end

  def make
    loop do
      sleep rand
      product = "Product no. #{next_product_no} by #{Thread.current.name}"
      @factory.make product
    end
  end

  private

    def next_product_no
      @mutex.synchronize do
        @@product_no += 1
      end
    end
end

class Consumer
  def initialize(name, factory)
    Thread.current.name = name
    @factory = factory
  end

  def take
    loop do
      @factory.take
      sleep rand
    end
  end
end

factory = Factory.new(3)

producers = 3.times.map { |i|
  Thread.new do
    Producer.new("P-#{i + 1}", factory).make
  end
}

consumers = 3.times.map { |i|
  Thread.new do
    Consumer.new("C-#{i + 1}", factory).take
  end
}

producers.each(&:join)
consumers.each(&:join)
