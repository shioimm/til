# 引用: Rubyアプリケーションプログラミング P161

require 'thread'

t = Thread.start {
  loop do
    puts 'hello'
    sleep(1)
  end
}

# Thread.kill(Thread.current
Thread.exit

p t.alive?
