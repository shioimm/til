# 引用: Working with TCP Sockets P152

require 'socket'
require 'thread'
require_relative '../command_handler'

module FTP
  Connection = Struct.new(:client) do
    CRLF = "\r\n"

    def gets
      client.gets(CRLF)
    end

    def respond(message)
      client.write(message)
      client.write(CRLF)
    end

    def close
      client.close
    end
  end

  class ThreadPerConnection
    def initialize(port = 21)
      @control_socket = TCPServer.new(port)

      trap(:INT) { exit }
    end

    def run
      Thread.abort_on_exception = true

      loop do
        conn = Connection.new(@control_socket.accept)

        Thread.new do
          conn.respond "220 OHAI"

          handler = FTP::CommandHandler.new(conn)

          loop do
            request = conn.gets

            if request
              conn.respond handler.handle(request)
            else
              conn.close
              break
            end
          end
        end
      end
    end
  end
end

server = FTP::ThreadPerConnection.new(4481)
server.run
