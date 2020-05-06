# 引用: Working with TCP Sockets (Jesse Storimer)
# Our First Client/Server

require 'socket'

module CloudHash
  class Client
    class << self
      attr_accessor :host, :port
    end

    def self.get(key)
      request "GET #{key}"
    end

    def self.set(key, value)
      request "SET #{key} #{value}"
    end

    def self.request(string)
      @client = TCPSocket.new(host, port)
      @client.write(string) # 渡された文字列を接続ソケットに書き込む
      @client.close_write # 書き込み用のIOを閉じる
      @client.read # EOFまで読み込み
    end
  end
end

CloudHash::Client.host = 'localhost'
CloudHash::Client.port = 4481

puts CloudHash::Client.set 'prez', 'obama'
puts CloudHash::Client.get 'prez'
puts CloudHash::Client.get 'vp'
