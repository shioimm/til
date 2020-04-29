# 引用: Working with TCP Sockets (Jesse Storimer)
# Our First Client/Server
# Framing Messages

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

    SIZE_OF_INT = [11].pack('i').size # 引数で指定した文字列に従い、配列の内容をバイナリとしてパック

    def handle(connection)
      # メッセージサイズを固定幅に詰め込んでunpack
      packed_msg_length = connection.read(SIZE_OF_INT)
      msg_length = packed_msg_length.unpack('i').first

      # メッセージの長さを指定してメッセージ全文を取得
      request = connection.read(msg_length)
      connection.write process(request)
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
