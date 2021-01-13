CONCURRENCY = 4
pids = []

CONCURRENCY.times do |i|
  pids << fork do
    puts "#{i + 1}: PID=#{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"

    sleep 1
  end
end

pids.each do |pid|
  exited_pid = Process.waitpid(pid)

  puts "ID=#{exited_pid.object_id} was exited - #{Time.now.strftime('%H:%M:%S')}"
end

# $ ruby practices/ruby/concurrency/proccess.rb
#
# 2: PID=67400 - 14:09:00
# 1: PID=67399 - 14:09:00
# 3: PID=67401 - 14:09:00
# 4: PID=67402 - 14:09:00
#
# PID=67399 was exited - 14:09:01
# PID=67400 was exited - 14:09:01
# PID=67401 was exited - 14:09:01
# PID=67402 was exited - 14:09:01
