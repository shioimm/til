require_relative './parser.rb'

module Quack
  class ServerProtocol
    def initialize
      @parser = Quack::Parser.new
    end

    def receive(message)
      @message = @parser.parse(message)
    end

    def response
      if authorized?
        "#{header}\r\n\r\n#{body}"
      else
        "HTTP/DUCK 600 YouAreTheUglyDuckling"
      end
    end

    private

      def authorized?
        @message[:method] != 'OTHER'
      end

      def header
        case @message[:method]
        when "GET"
          "HTTP/DUCK 200 OK"
        end
      end

      def body
        case @message[:method]
        when "GET"
          "You must to be a duck"
        end
      end
  end
end
