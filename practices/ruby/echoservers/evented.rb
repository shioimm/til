require 'socket'

class Evented
  DATA_SIZE = 16 * 1024

  def initialize(host, port)
    @listener = TCPServer.open(host, port)
    @handles = {}

    _protocol, port, host, _ipaddr = @listener.addr
    puts "Server is running on #{host}:#{port}"

    trap(:INT) do
      puts "Shutdown on #{Time.now.strftime("%Y/%m/%d %H:%M")}"
      exit
    end
  end

  def run
    loop do
      # WIP
    end
  end

  private attr_reader :listener
end

HOST = 'localhost'
PORT = 12345

server = Evented.new(HOST, PORT)
server.run
