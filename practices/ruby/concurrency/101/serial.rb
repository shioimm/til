CONCURRENCY = 4

CONCURRENCY.times do |i|
  puts "#{i + 1}: PID=#{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"
  sleep 1
end

# $ ruby practices/ruby/concurrency/serial.rb
# 1: PID=65016 - 12:23:53
# 2: PID=65016 - 12:23:54
# 3: PID=65016 - 12:23:55
# 4: PID=65016 - 12:23:56
