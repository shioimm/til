require 'socket'

request_message = File.open(ARGV[0]) { |f| f.read }

sock = TCPSocket.new('localhost', 9292)
sock.write(request_message)

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
