writer = Ractor.new do
  10.times do
    count, reader = Ractor.receive

    File.open('ractor_counter', File::RDWR | File::CREAT) do |f|
      f.rewind
      f.write count
    end

    reader.send self
  end
end

Ractor.new(writer) do |writer|
  10.times do
    File.open('ractor_counter', File::RDWR | File::CREAT) do |f|
      ex_count = f.read.to_i
      count = ex_count + 1
      writer.send [count, Ractor.current]
    end

    Ractor.receive
  end
end.take

puts File.read('ractor_counter').to_i
