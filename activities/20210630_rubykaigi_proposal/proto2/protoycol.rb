require 'socket'
require_relative './protoycol/protocol'
require_relative './protoycol/config/const'

Dir["#{__dir__}/protoycol/protocols/*.rb"].sort.each { |f| require f }

module Protoycol
  class Proxy
    def initialize(host, port)
      @host           = host
      @port           = port
      @request_method = nil
      @path           = nil
      @query          = nil
      @input          = nil
      @protocol       = ::Protoycol::Protocol
    end

    def start
      server = TCPServer.new(@host, @port)

      puts <<~MESSAGE
      Protoycol is running on #{@host}:#{@port}
      => Use Ctrl-C to stop
      MESSAGE

      loop do
        socket = server.accept

        while !socket.closed? && !socket.eof?
          request = socket.readpartial(1024)

          begin
            puts "[Protoycol] Received request message: " \
                 + "#{request.inspect.chomp}"

            safe_execution { @protocol.run!(request) }

            @request_method = @protocol.request_method
            @path  = @protocol.request_path
            @query = @protocol.query
            @input = @protocol.input
            @content_length = @input&.bytesize || 0

            http_request_message = build_http_request_message

            puts "[Protoycol] Request message has been translated to HTTP request message: " \
                 + http_request_message.inspect

            UNIXSocket.open(Config::UNIX_SOCKET_PATH) do |appserver|
              appserver.write http_request_message
              puts "[Protoycol] Successed to Send request message"

              while !appserver.closed? && !appserver.eof?
                message = appserver.read_nonblock(1024)
                puts "[Protoycol] Received response message: #{message.lines.first.inspect}"

                begin
                  socket.write message
                rescue StandardError => e
                  puts "[Protoycol] #{e.class} #{e.message} - closing socket"
                  e.backtrace.each { |l| puts "\t" + l }
                ensure
                  appserver.close
                end
              end
            end

          rescue StandardError => e
            puts "#{e.class} #{e.message} - closing socket."
            e.backtrace.each { |l| puts "\t" + l }
            server.close
          ensure
            socket.close
          end
        end
      end
    end

    private

      NEWLINE = "\r\n"
      private_constant :NEWLINE

      def response_line(status)
        "HTTP/1.1 #{status} #{@protocol.status_message(status)}"
      end

      def response_header(headers)
        headers.map { |k, v| "#{k}: #{v}" }.join(', ')
      end

      def response_body(body)
        rbody = []
        body.each { |body| rbody << body }
        rbody.join("\n")
      end

      def tp
        @tp ||= TracePoint.new(:script_compiled) { |tp|
          if tp.binding.receiver == @protocol && tp.method_id.to_s.match?(disallowed_methods_regex)
            raise 'Disallowed method was executed'
          end
        }
      end

      def safe_execution
        tp.enable { yield }
      end

      def disallowed_methods_regex
        /(.*eval|.*exec|`.+|%x\(|system|open|require|load)/
      end

      def build_http_request_message
        request_message = "#{request_line}" + "#{request_header}" + "#{NEWLINE}"
        request_message.concat "#{@input + NEWLINE}" if @input
        request_message
      end

      def request_line
        "#{@request_method} #{request_path} HTTP/1.1\r\n"
      end

      def request_path
        case @request_method
        when "GET"
          "#{@path}#{'?' + @query if @query && !@query.empty?}"
        else
          @path
        end
      end

      def request_header
        "Content-Length: #{@content_length}\r\n"
      end
  end
end
