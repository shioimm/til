CONCURRENCY = 4

threads = []

CONCURRENCY.times do |i|
  threads << Thread.new do
    puts "#{i + 1}: ObjectID=#{Thread.current.object_id} / PID=#{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"

    sleep 1
  end
end

threads.each do |thread|
  puts "ObjectID=#{thread.join.object_id} was joined - #{Time.now.strftime('%H:%M:%S')}"
end

# 1: ObjectID=60  / PID=90506 - 16:10:47
# 3: ObjectID=80  / PID=90506 - 16:10:47
# 4: ObjectID=100 / PID=90506 - 16:10:47
# 2: ObjectID=120 / PID=90506 - 16:10:47
# ObjectID=60  was joined - 16:10:48
# ObjectID=120 was joined - 16:10:48
# ObjectID=80  was joined - 16:10:48
# ObjectID=100 was joined - 16:10:48

# thread.joinを呼ばない場合
# ObjectID=60  was joined - 16:11:49
# ObjectID=80  was joined - 16:11:49
# ObjectID=120 was joined - 16:11:49
# 3: ObjectID=120 / PID=90629 - 16:11:49
# ObjectID=100 was joined - 16:11:49
