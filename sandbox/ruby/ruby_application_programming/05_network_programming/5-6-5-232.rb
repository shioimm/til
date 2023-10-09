# 引用: Rubyアプリケーションプログラミング P232

require 'socket'
require 'thread'

gate = TCPServer.open(12345)
m    = Mutex.new

srand

def gen_question(length)
  n = rand(9) + 1
  correct = n
  question = n.to_s

  (2..length).each do
    n = rand(9) + 1
    correct += n
    question += " + #{n}"
  end

  return correct, question
end

loop do
  sock = gate.accept

  begin
    sock.write "Are you ready?\n"

    5.downto(1).each do |count|
      sleep 1
      sock.write "#{'.' * count} #{count}\n"
    end
  rescue
    sock.close
    next
  end

  answer = 0

  th_read = Thread.start {
    while msg = sock.gets
      m.synchronize { answer = msg.chomp.to_i }
    end
    sock.write "Stop\n"
    sock.close
  }

  th_write = Thread.start {
    sleep 1
    sock.write "Start\n"
    right = 0

    (1..12).each do |n|
      correct, question = gen_question((n - 1) / 3 + 2)

      m.synchronize { answer = 0 }
      sock.write "(#{n}) #{question} \n"
      sleep 1

      4.downto(1).each do |count|
        sock.write "#{'.' * count}\n"
        sleep 1
      end

      m.synchronize { right += 1 if correct == answer}
    end

    sock.write "Finish\n"
    sock.write "You gave the #{right} / 12 right answer\n"
  }

  begin
    th_write.join
  rescue
  end

  th_read.exit if th_read.alive?

  sock.close
end
