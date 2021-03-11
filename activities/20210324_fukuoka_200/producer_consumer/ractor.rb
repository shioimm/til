class Producer
  def initialize(channel, numbering)
    @channel = channel
    @numbering = numbering
  end

  def run
    loop do
      sleep rand
      product_no = issue_product_no
      product = "Product no. #{product_no} by #{Ractor.current.name}"
      @channel.send product
      puts "#{Ractor.current.name} makes #{product}."
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
      puts "#{Ractor.current.name} takes #{product}"
      sleep rand
    end
  end
end

channel = Ractor.new do
  loop do
    product = Ractor.receive
    Ractor.yield product
  end
end

numbering = Ractor.new(no = 1) do |no|
  loop do
    producer = Ractor.receive
    producer.send no
    no += 1
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
