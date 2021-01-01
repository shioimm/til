require 'socket'

class Serial
  def initialize(host, port)
    @listener = TCPServer.open(host, port)

    _protocol, port, host, _ipaddr = @listener.addr
    puts "Server is running on #{host}:#{port}"

    trap(:INT) do
      puts "Shutdown on #{Time.now.strftime("%Y/%m/%d %H:%M")}"
      exit
    end
  end

  def run
    loop do
      begin
        conn = listener.accept

        loop do
          msg = conn.read_nonblock(1024)
          conn.puts msg
        end
      rescue Errno::EAGAIN
      ensure
        conn.close if conn
      end
    end
  end

  private attr_reader :listener
end

HOST = 'localhost'
PORT = 12345

server = Serial.new(HOST, PORT)
server.run
