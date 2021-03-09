class Channel
  def initialize(size)
    @in_progress_products = []
    @max_size = size # 同時に作ることができる最大数
    @mutex    = Mutex.new
    @cond     = ConditionVariable.new
  end

  def make(product)
    @mutex.synchronize do
      while @in_progress_products.size >= @max_size # 最大仕掛かり数 >= 同時に作ることができる最大数
        @cond.wait(@mutex)
      end

      @in_progress_products.push product
      puts "#{Thread.current.name} makes #{product}. WIP: #{@in_progress_products.size}/#{@max_size}"
      @cond.signal
    end
  end

  def take
    @mutex.synchronize do
      while @in_progress_products.size <= 0 # 最大仕掛かり数 <= 0
        @cond.wait(@mutex)
      end

      product = @in_progress_products.pop
      @cond.signal
      puts "#{Thread.current.name} takes #{product}. WIP: #{@in_progress_products.size}/#{@max_size}"
      product
    end
  end
end

class Numbering
  @@product_no = 0

  def self.issue
    Mutex.new.synchronize do
      @@product_no += 1
    end
  end
end

class Producer
  def initialize(name, channel)
    Thread.current.name = name
    @channel = channel
    @mutex   = Mutex.new
  end

  def make
    loop do
      sleep rand
      product_no = Numbering.issue
      product = "Product no. #{product_no} by #{Thread.current.name}"
      @channel.make product
    end
  end
end

class Consumer
  def initialize(name, channel)
    Thread.current.name = name
    @channel = channel
  end

  def take
    loop do
      @channel.take
      sleep rand
    end
  end
end

channel = Channel.new(3)

producers = 3.times.map { |i|
  Thread.new do
    Producer.new("P-#{i + 1}", channel).make
  end
}

consumers = 3.times.map { |i|
  Thread.new do
    Consumer.new("C-#{i + 1}", channel).take
  end
}

producers.each(&:join)
consumers.each(&:join)
