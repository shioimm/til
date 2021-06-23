require_relative './parser.rb'

module Ruby
  class ServerProtocol
    def initialize
      @parser = Ruby::Parser.new
    end

    def receive(message)
      @message = @parser.parse(message)
    end

    def response
      if authorized?
        "#{header}\r\n\r\n#{body}"
      else
        "HTTP/RUBY 600 AreYouARubyProgrammer"
      end
    end

    private

      def authorized?
        @message[:method] != 'OTHER'
      end

      def header
        case @message[:method]
        when "GET"
          "HTTP/RUBY 200 OK"
        end
      end

      def body
        case @message[:method]
        when "GET"
          "You seems to be a Ruby programmer"
        end
      end
  end
end
