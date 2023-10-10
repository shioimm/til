# 引用: Rubyアプリケーションプログラミング P163

require 'thread'

line_queue = []

print_thread = Thread.start {
  loop do
    if line_queue.empty?
      Thread.stop
    else
      if line = line_queue.shift
        print(line)
      else
        Thread.exit
      end
    end
  end
}

begin
  line = gets
  line_queue.push(line)

  if print_thread.stop?
    print_thread.wakeup
  end
end while line

print_thread.join
