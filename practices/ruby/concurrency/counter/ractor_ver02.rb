r = Ractor.current

10.times do
  r = Ractor.new(r) do |r|
    ex_count = Ractor.receive
    count = ex_count + 1

    File.open('ractor_counter', File::RDWR | File::CREAT) do |f|
      f.rewind
      f.write count
    end

    r.send count
  end
end

r.send 0
Ractor.receive

puts File.read('ractor_counter').to_i
