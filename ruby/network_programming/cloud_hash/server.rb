# 引用: Working with TCP Sockets (Jesse Storimer)
# Our First Client/Server

require 'socket'

module CloudHash
  class Server
    def initialize(port)
      @server = TCPServer.new(port)
      puts "Listening on port #{@server.local_address.ip_port}" # ローカルアドレスのポート番号
      @storage = {}
    end

    def start
      # @serverを受け取って接続を待ち受ける
      # クライアントとの接続確立時、ブロックに接続ソケットを渡す
      Socket.accept_loop(@server) do |connection|
        handle(connection)
        connection.close # 接続を切断
      end
    end

    def handle(connection)
      request = connection.read # コネクションから読み込み
      connection.write process(request) # コネクションにprocessハッシュを返す
    end

    def process(request)
      command, key, value = request.split

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
