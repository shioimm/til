class Channel
  def initialize(size)
    @products = []   # Channelが保有しているproduct
    @max_size = size # Channelが同時保有することができる最大数
    @mutex    = Mutex.new
    @cond     = ConditionVariable.new
  end

  def put(product)
    @mutex.synchronize do
      while @products.size >= @max_size # 現在の保有数 >= 最大保有数
        @cond.wait(@mutex)
      end

      @products.push product
      puts "#{Thread.current.name} produces #{product}"
      @cond.signal
    end
  end

  def take
    @mutex.synchronize do
      while @products.size <= 0 # 現在の保有数 <= 0
        @cond.wait(@mutex)
      end

      product = @products.pop
      @cond.signal
      puts "#{Thread.current.name} consumes #{product}."
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
  end

  def run
    loop do
      sleep rand
      product_no = Numbering.issue
      product = "Product no. #{product_no} by #{Thread.current.name}"
      @channel.put product
    end
  end
end

class Consumer
  def initialize(name, channel)
    Thread.current.name = name
    @channel = channel
  end

  def run
    loop do
      @channel.take
      sleep rand
    end
  end
end

channel = Channel.new(3)

producers = 3.times.map { |i|
  Thread.new do
    Producer.new("P-#{i + 1}", channel).run
  end
}

consumers = 3.times.map { |i|
  Thread.new do
    Consumer.new("C-#{i + 1}", channel).run
  end
}

producers.each(&:join)
consumers.each(&:join)
