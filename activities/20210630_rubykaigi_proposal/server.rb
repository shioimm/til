require 'socket'
require_relative './protocols/quack/server_protocol'
require_relative './protocols/ruby/server_protocol'

protocol = Object.const_get("#{ARGV[0]}::ServerProtocol").new
listening_sock = TCPServer.open(12345)

loop do
  connecting_sock = listening_sock.accept

  while !connecting_sock.closed? && !connecting_sock.eof?
    message = connecting_sock.readpartial(1024)

    begin
      puts "RECEIVED MESSAGE: #{message.inspect.chomp}"

      protocol.receive(message)
      response = protocol.response

      connecting_sock.write response
    rescue StandardError => e
      puts "#{e.class} #{e.message} - closing socket."
      e.backtrace.each { |l| puts "\t" + l }
      listening_sock.close
    ensure
      connecting_sock.close
    end
  end
end
