m = Mutex.new

ts = 10.times.map do
  Thread.fork do
    m.synchronize do
      File.open('thread_counter', File::RDWR | File::CREAT) do |f|
        ex_count = f.read.to_i
        count = ex_count + 1
        f.rewind
        f.write count
      end
    end
  end
end

ts.each(&:join)

puts File.read('thread_counter').to_i
