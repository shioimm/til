CONCURRENCY = 4

ractors = CONCURRENCY.times.map do |i|
  Ractor.new(i) do |i|
    puts "#{i + 1}: ObjectID: #{Ractor.current.object_id} / PID: #{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"

    sleep 1
  end
end

ractors.each do |ractor|
  ractor.take # main Ractorで待ち合わせ
  puts "ObjectID: #{ractor.object_id} was already taken - #{Time.now.strftime('%H:%M:%S')}"
end

# 4: ObjectID=120 / PID=90338 - 16:03:49
# 3: ObjectID=100 / PID=90338 - 16:03:49
# 1: ObjectID=60  / PID=90338 - 16:03:49
# 2: ObjectID=80  / PID=90338 - 16:03:49
# ObjectID=60  already taken - 16:03:50
# ObjectID=80  already taken - 16:03:50
# ObjectID=100 already taken - 16:03:50
# ObjectID=120 already taken - 16:03:50

# ractor.takeを呼ばなかった場合
# 1: ObjectID=60  / PID=90416   - 16:06:45
# ObjectID=60  was already taken  - 16:06:45
# 2: ObjectID=80  / PID=90416   - 16:06:45
# 3: ObjectID=100 / PID=90416   - 16:06:45
# ObjectID=80  was already taken  - 16:06:45
# 4: ObjectID=120 / PID=90416   - 16:06:45
# ObjectID=100 was already taken - 16:06:45
# ObjectID=120 was already taken - 16:06:45
