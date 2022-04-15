class Producer
  def initialize(channel, numbering)
    @channel = channel
    @numbering = numbering
  end

  def run
    loop do
      product_no = issue_product_no
      @channel.send ["Product no. #{product_no}", Ractor.current.name]
    end
  end

  def issue_product_no
    @numbering.send Ractor.current
    Ractor.receive
  end
end

class Consumer
  def initialize(channel)
    @channel = channel
  end

  def run
    loop do
      product = @channel.take
      puts "#{Ractor.current.name} consumes #{product}"
    end
  end
end

channel = Ractor.new do
  loop do
    product, producer = Ractor.receive
    puts "#{producer} produces #{product}"

    Ractor.yield product
  end
end

numbering = Ractor.new(no = 0) do |no|
  loop do
    no += 1
    producer = Ractor.receive
    producer.send no
  end
end

producers = 3.times.map { |i|
  Ractor.new(channel, numbering, name: "P-#{i + 1}") do |channel, numbering|
    Producer.new(channel, numbering).run
  end
}

consumers = 3.times.map { |i|
  Ractor.new(channel, name: "C-#{i + 1}") do |channel|
    Consumer.new(channel).run
  end
}

producers.each(&:take)
consumers.each(&:take)
