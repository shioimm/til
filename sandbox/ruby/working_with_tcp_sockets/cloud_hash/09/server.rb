# 引用: Working with TCP Sockets P72

require 'socket'

module CloudHash
  class Server
    def initialize(port)
      @server = TCPServer.new(port)
      @storage = {}

      puts "Listening on port #{@server.local_address.ip_port}"
    end

    def start
      Socket.accept_loop(@server) do |connection|
        handle(connection)
        connection.close
      end
    end

    def handle(connection)
      request = connection.read

      connection.write process(request)
    end

    def process(request)
      command, key, value = request.split
      puts "Received request: #{command}: #{key}#{'=' + value if value}"

      case command.upcase
      when 'GET'
        @storage[key]
      when 'SET'
        @storage[key] = value
      end
    end
  end
end

server = CloudHash::Server.new(4481)
server.start
