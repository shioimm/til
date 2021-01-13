CONCURRENCY = 4

CONCURRENCY.times do |i|
  puts "#{i + 1}: #{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"
  sleep 1
end

# $ ruby practices/ruby/concurrency/serial.rb
# 1: 65016 - 12:23:53
# 2: 65016 - 12:23:54
# 3: 65016 - 12:23:55
# 4: 65016 - 12:23:56
