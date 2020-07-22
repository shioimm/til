# 引用: Working with TCP Sockets (Jesse Storimer)
# Our First Client/Server
# Framing Messages

require 'socket'

module CloudHash
  class Client
    def initialize(host, port)
      @connection = TCPSocket.new(host, port)
    end

    def get(key)
      request "GET #{key}"
    end

    def set(key, value)
      request "SET #{key} #{value}"
    end

    def request(string)
      @connection.puts(string) # 渡された文字列をソケットに書き込む
      @connection.gets # 改行を受けるまで読み込む
    end
  end
end

client = CloudHash::Client.new('localhost', 4481)

puts client.set 'prez', 'obama'
puts client.get 'prez'
puts client.get 'vp'
