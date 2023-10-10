# 引用: Working with TCP Sockets P73

require 'socket'

module CloudHash
  class Client
    class << self
      attr_accessor :host, :port

      def get(key)
        request "GET #{key}"
      end

      def set(key, value)
        request "SET #{key} #{value}"
      end

      def request(string)
        @client = TCPSocket.new(host, port)
        @client.write(string)
        @client.close_write
        @client.read
      end
    end
  end
end

CloudHash::Client.host = 'localhost'
CloudHash::Client.port = 4481

puts CloudHash::Client.set 'prez', 'obama'
puts CloudHash::Client.get 'prez'
puts CloudHash::Client.get 'vp'
