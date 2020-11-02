# 引用: Working with TCP Sockets P73 / 107

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
      @connection.puts(string)
      @connection.gets
    end
  end
end

client = CloudHash::Client.new('localhost', 4481)

puts client.set 'prez', 'obama'
puts client.get 'prez'
puts client.get 'vp'
