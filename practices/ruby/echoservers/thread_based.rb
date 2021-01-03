require 'socket'

class ThreadBased
  DATA_SIZE = 1024

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
    Thread.abort_on_exception = true

    loop do
      Thread.new(listener.accept) do |conn|
        begin
          msg = conn.readpartial(DATA_SIZE)

          puts "Client requests: #{msg.split("\r\n").first}"

          conn.puts '-- Server received the request message --'
          conn.puts "\r\n"
          conn.puts msg
        ensure
          conn.shutdown
        end
      end
    end
  end

  private attr_reader :listener
end

HOST = 'localhost'
PORT = 12345

server = ThreadBased.new(HOST, PORT)
server.run
