class Producer
  def initialize(factory)
    @id = 0
    @factory = factory
  end

  def make
    loop do
      sleep rand
      product = "Product no. #{@id} by #{Ractor.current.name}"
      @factory.send product
      puts "#{Ractor.current.name} makes #{product}."
    end
  end
end

class Consumer
  def initialize(factory)
    @factory = factory
  end

  def take
    loop do
      product, _ = @factory.take
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
  Ractor.new(factory, name: "P-#{i + 1}") do |factory|
    Producer.new(factory).make
  end
}

consumers = 3.times.map { |i|
  Ractor.new(factory, name: "C-#{i + 1}") do |factory|
    Consumer.new(factory).take
  end
}

producers.each(&:take)
consumers.each(&:take)
