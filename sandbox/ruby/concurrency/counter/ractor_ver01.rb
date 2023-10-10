10.times do
  Ractor.new do
    File.open('ractor_counter', File::RDWR | File::CREAT) do |f|
      ex_count = f.read.to_i
      count = ex_count + 1
      f.rewind
      f.write count
    end
  end
end

puts File.read('ractor_counter').to_i
