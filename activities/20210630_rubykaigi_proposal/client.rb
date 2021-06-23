require 'socket'

request_message = File.open(ARGV[0]) do |f|
  f.read
end

sock = TCPSocket.new('localhost', 12345)
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
