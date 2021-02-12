pids = 10.times.map do
  Process.fork do
    File.open('process_counter', File::RDWR | File::CREAT) do |f|
      ex_count = f.read.to_i
      count = ex_count + 1
      f.rewind
      f.write count
    end
  end
end

pids.each { |pid| Process.waitpid(pid) }

puts File.read('process_counter').to_i
