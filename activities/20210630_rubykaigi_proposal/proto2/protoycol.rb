require 'socket'
require 'rack/handler'
require 'rack/handler/puma'

require_relative './protocol'
require_relative './config/const'

Dir["#{__dir__}/config/protocols/*.rb"].sort.each { |f| require f }

UNIX_FILE_PARH = '/tmp/protoycol.socket'

module Rack
  module Handler
    class Protoycol
      def self.run(app, options = {})
        if child_pid = fork
          puts "Protoycol starts Puma in single mode, listening on unix://#{UNIX_FILE_PARH}"
          Rack::Handler::Puma.run(app, { Host: UNIX_FILE_PARH, Silent: true })
          Process.waitpid(child_pid)
        else
          environment  = ENV['RACK_ENV'] || 'development'
          default_host = environment == 'development' ? ::Config::LOCALHOST : ::Config::DEFAULT_HOST

          host = options.delete(:Host) || default_host
          port = options.delete(:Port) || ::Config::DEFAULT_PORT
          args = [host, port]

          ::Protoycol.new(host, port).start
        end
      end
    end

    register :protoycol, Protoycol
  end
end

class Protoycol
  def initialize(host, port)
    @host           = host
    @port           = port
    @request_method = nil
    @path           = nil
    @query          = nil
    @input          = nil
    @protocol       = ::Protocol
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
          puts "[Protoycol] Received request message:" \
               + "#{request.inspect.chomp}"

          safe_execution { @protocol.run!(request) }

          @request_method = @protocol.request_method
          @path  = @protocol.request_path
          @query = @protocol.query

          # for POST message
          @input = @protocol.input
          @content_length = @input&.bytesize

          http_request_message = build_http_request_message

          puts "[Protoycol] Request message has been translated to HTTP request message:" \
               + http_request_message.inspect

          UNIXSocket.open(UNIX_FILE_PARH) do |appserver|
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
      case @request_method
      when "GET"
        "#{@request_method} #{@path}#{'?' + @query if @query && !@query.empty?} HTTP/1.1\r\n" \
        + "\r\n"
      when "POST"
        "#{@request_method} #{@path} HTTP/1.1\r\n" \
        + "Content-Length: #{@content_length}\r\n" \
        + "\r\n" \
        + "#{@input}\r\n" \
        + "\r\n"
      end
    end
end
