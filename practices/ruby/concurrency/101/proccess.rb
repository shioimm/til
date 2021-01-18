CONCURRENCY = 4
pids = []

CONCURRENCY.times do |i|
  pids << fork do
    puts "#{i + 1}: PID=#{Process.pid} - #{Time.now.strftime('%H:%M:%S')}"

    sleep 1
  end
end

pids.each do |pid|
  puts "PID=#{Process.waitpid(pid)} was exited - #{Time.now.strftime('%H:%M:%S')}"
end

# 2: PID=87285 - 12:33:57
# 1: PID=87284 - 12:33:57
# 3: PID=87286 - 12:33:57
# 4: PID=87287 - 12:33:57
# PID=87284 was exited - 12:33:58
# PID=87285 was exited - 12:33:58
# PID=87286 was exited - 12:33:58
# PID=87287 was exited - 12:33:58

# Process.waitpid(pid)を呼ばない場合
# PID=87405 was exited - 12:35:01
# PID=87406 was exited - 12:35:01
# PID=87407 was exited - 12:35:01
# PID=87408 was exited - 12:35:01
# 2: PID=87406 - 12:35:01
# 1: PID=87405 - 12:35:01
# 3: PID=87407 - 12:35:01
# 4: PID=87408 - 12:35:01
# 親プロセスが先に終了する
# ゾンビ状態の子プロセスが発生する
