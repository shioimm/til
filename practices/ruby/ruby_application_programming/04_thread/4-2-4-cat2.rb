# 引用: Rubyアプリケーションプログラミング P165

require 'thread'

line_queue = Queue.new

print_thread = Thread.start {
  while line = line_queue.deq
    print(line)
  end
}

begin
  line = gets
  line_queue.enq(line)
end while line

print_thread.join
