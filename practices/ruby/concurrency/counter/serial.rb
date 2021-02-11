10.times do
  File.open('serial_counter', File::RDWR | File::CREAT) do |f|
    ex_count = f.read.to_i
    count = ex_count + 1
    f.rewind
    f.write count
  end
end

puts File.read('serial_counter').to_i
