calculater = Ractor.new do
  loop do
    ex_count = Ractor.receive
    count = ex_count + 1
    Ractor.yield count
  end
end

rs = 10.times.map do
  Ractor.new(calculater) do |calculater|
    count = calculater.take

    File.open('ractor_counter', File::RDWR | File::CREAT) do |f|
      f.rewind
      f.write count
    end

    calculater.send count
  end
end

calculater.send 0
rs.each(&:take)

puts File.read('ractor_counter').to_i
