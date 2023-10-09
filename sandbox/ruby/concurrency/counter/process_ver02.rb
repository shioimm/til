r, w = IO.pipe

pids = 10.times.map do
  Process.fork do
    ex_count = r.gets.to_i
    count = ex_count + 1

    File.open('process_counter', File::RDWR | File::CREAT) do |f|
      f.rewind
      f.write count
    end

    w.puts count
  end
end

w.puts 0

pids.each { |pid| Process.waitpid(pid) }

puts File.read('process_counter').to_i
