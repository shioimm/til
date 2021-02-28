class Producer
  @@id = 0

  def initialize(name, factory)
    Ractor.current.name = name
    @factory = factory
  end

  def make
    loop do
      sleep rand
      product = "Product no. #{next_id} by #{Ractor.current.name}"
      @factory.send product
      puts "#{Ractor.current.name} makes #{product}."
    end
  end

  private

    def next_id
      @@id += 1
    end
end

class Consumer
  def initialize(name, factory)
    Ractor.current.name = name
    @factory = factory
  end

  def take
    loop do
      product = @factory.take
      puts "#{Ractor.current.name} takes #{product}"
      sleep rand
    end
  end
end

factory = Ractor.new do
  loop do
    product = Ractor.recv
    Ractor.yield product
  end
end

producers = 3.times.map { |i|
  Ractor.new do
    Producer.new("P-#{i + 1}", factory).make
  end
}

consumers = 3.times.map { |i|
  Ractor.new do
    Consumer.new("C-#{i + 1}", factory).take
  end
}

producers.each(&:take)
consumers.each(&:take)
