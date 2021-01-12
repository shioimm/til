CONCURRENCY = 4

ractors = CONCURRENCY.times.map do |i|
  Ractor.new(i) do |i|
    puts "#{i + 1}: ID=#{Ractor.current.object_id} / PID=#{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"

    sleep 1
  end
end

ractors.each do |ractor|
  ractor.take

  puts "#{ractor.object_id} was already terminated - #{Time.now.strftime('%H:%M:%S')}"
end

# $ ruby practices/ruby/concurrency/ractor.rb
#
# 2: ID=80  / PID=14520 - 21:29:44
# 1: ID=60  / PID=14520 - 21:29:44
# 3: ID=100 / PID=14520 - 21:29:44
# 4: ID=120 / PID=14520 - 21:29:44
#
# 60  was already terminated - 21:29:45
# 80  was already terminated - 21:29:45
# 100 was already terminated - 21:29:45
# 120 was already terminated - 21:29:45
