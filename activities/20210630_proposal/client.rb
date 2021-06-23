require 'socket'

HOSTNAME = 'localhost'
PATH = '/'

MESSAGE = <<~MESSAGE
Would you do me a favor?\n
I would like to GET #{PATH}
MESSAGE

sock = TCPSocket.new('localhost', 12345)
sock.write(MESSAGE)

while !sock.closed? && !sock.eof?
  message = sock.read_nonblock(1024)

  begin
    puts message
  rescue StandardError => e
    puts "#{e.class} #{e.message} - closing socket."
    e.backtrace.each { |l| puts "\t" + l }
   ensure
    sock.close
  end
end
