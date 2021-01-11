CONCURRENCY = 4

threads = []

CONCURRENCY.times do |i|
  threads << Thread.new do
    puts "#{i + 1}: ID=#{Thread.current.object_id} / PID=#{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"

    sleep 1
  end
end

threads.each do |thread|
  dead_thread = thread.join

  puts "ID=#{dead_thread.object_id} was dead - #{Time.now.strftime('%H:%M:%S')}"
end

# $ ruby practices/ruby/concurrency/thread.rb
#
# 1: ID=60  / PID=67149 - 14:03:54
# 2: ID=80  / PID=67149 - 14:03:54
# 4: ID=100 / PID=67149 - 14:03:54
# 3: ID=120 / PID=67149 - 14:03:54
#
# ID=60  was dead - 14:03:55
# ID=80  was dead - 14:03:55
# ID=120 was dead - 14:03:55
# ID=100 was dead - 14:03:55
