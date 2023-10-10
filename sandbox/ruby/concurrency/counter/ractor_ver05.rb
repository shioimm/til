pipe = Ractor.new do
  loop do
    Ractor.yield Ractor.receive
  end
end

reader = Ractor.new(pipe) do |pipe|
  10.times do
    File.open('ractor_counter', File::RDWR | File::CREAT) do |f|
      ex_count = f.read.to_i
      count = ex_count + 1
      pipe.send [count, self]
    end

    Ractor.receive
  end
end

writer = Ractor.new(pipe) do |pipe|
  10.times do
    count, waiter = pipe.take

    File.open('ractor_counter', File::RDWR | File::CREAT) do |f|
      f.rewind
      f.write count
    end

    waiter.send self
  end
end

[reader, writer].each(&:take)

puts File.read('ractor_counter').to_i
