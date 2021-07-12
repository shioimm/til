require 'socket'

module Toycol
  class Proxy
    include Helper

    def initialize(host, port)
      @host           = host
      @port           = port
      @request_method = nil
      @path           = nil
      @query          = nil
      @input          = nil
      @protocol       = ::Toycol::Protocol
    end

    def start
      server = TCPServer.new(@host, @port)

      puts <<~MESSAGE
      Toycol is running on #{@host}:#{@port}
      => Use Ctrl-C to stop
      MESSAGE

      loop do
        trap(:INT) { shutdown }

        socket = server.accept

        while !socket.closed? && !socket.eof?
          request = socket.readpartial(1024)

          begin
            puts "[Toycol] Received request message: " \
                 + "#{request.inspect.chomp}"

            safe_execution { @protocol.run!(request) }

            @request_method = @protocol.request_method
            @path  = @protocol.request_path
            @query = @protocol.query
            @input = @protocol.input
            @content_length = @input&.bytesize || 0

            http_request_message = build_http_request_message

            puts "[Toycol] Request message has been translated to HTTP request message: " \
                 + http_request_message.inspect

            UNIXSocket.open(Config::UNIX_SOCKET_PATH) do |appserver|
              appserver.write http_request_message
              puts "[Toycol] Successed to Send request message"

              while !appserver.closed? && !appserver.eof?
                message = appserver.read_nonblock(1024)
                puts "[Toycol] Received response message: #{message.lines.first.inspect}"

                begin
                  socket.write message
                rescue StandardError => e
                  puts "[Toycol] #{e.class} #{e.message} - closing socket"
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

      def shutdown
        puts "[Toycol] Catched SIGINT -> Stop to server"
        exit
      end
  end
end

# メモ ---
# Puma::Server#run
# -> Puma::ThreadPoo.new
# -> Puma::Server#process_client
# -> Puma::Server#handle_request
# リクエストメソッドはPumaで検査されずアプリケーションへ渡される
# アプリケーションが返すレスポンスのステータスコードもPumaでは検査しない
