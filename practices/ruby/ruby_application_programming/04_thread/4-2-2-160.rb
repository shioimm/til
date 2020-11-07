# 引用: Rubyアプリケーションプログラミング P159

require 'thread'

threads = []

threads.push Thread.start {
  3.times do |n|
    puts "t1   ##{n + 1}"
    sleep(0.5)
  end
}

threads.push Thread.start {
  3.times do |n|
    puts "t2   ##{n + 1}"
    sleep(0.5)
  end
}

3.times do |n|
  puts "main ##{n + 1}"
  sleep(0.5)
end

threads.each do |t|
  t.join
end
