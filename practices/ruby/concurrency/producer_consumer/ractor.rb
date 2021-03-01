class Producer
  def initialize(factory, indexer)
    @factory = factory
    @indexer = indexer
  end

  def make
    loop do
      sleep rand
      product_no = ask_product_no

      product = "Product no. #{product_no} by #{Ractor.current.name}"
      @factory.send product
      puts "#{Ractor.current.name} makes #{product}."
    end
  end

  def ask_product_no
    @indexer.send Ractor.current
    Ractor.receive
  end
end

class Consumer
  def initialize(factory)
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
    product = Ractor.receive
    Ractor.yield product
  end
end

indexer = Ractor.new(no = 1) do |no|
  loop do
    producer = Ractor.receive
    producer.send no
    no += 1
  end
end

producers = 3.times.map { |i|
  Ractor.new(factory, indexer, name: "P-#{i + 1}") do |factory, indexer|
    Producer.new(factory, indexer).make
  end
}

consumers = 3.times.map { |i|
  Ractor.new(factory, name: "C-#{i + 1}") do |factory|
    Consumer.new(factory).take
  end
}

producers.each(&:take)
consumers.each(&:take)
