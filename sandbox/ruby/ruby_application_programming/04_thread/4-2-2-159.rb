# 引用: Rubyアプリケーションプログラミング P159

require 'thread'

t1 = Thread.start {
  5.times do |n|
    puts "t1   ##{n + 1}"
    sleep(0.5)
  end
}

3.times do |n|
  puts "main ##{n + 1}"
  sleep(0.5)
end

t1.join # 子スレッドが終了するまでメインスレッドの終了を待つ
