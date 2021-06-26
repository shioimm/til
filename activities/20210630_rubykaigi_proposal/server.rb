require 'socket'
require 'rack/handler'
require "stringio"
require_relative './protocol'
require_relative './config/const'

module Rack
  module Handler
    class Server
      def self.run(app, options = {})
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? ::Config::LOCALHOST : ::Config::DEFAULT_HOST

        host = options.delete(:Host) || default_host
        port = options.delete(:Port) || ::Config::DEFAULT_PORT
        args = [host, port, app]
        ::Server.new(*args).start
      end
    end

    register :server, Server
  end
end

class Server
  def initialize(*args)
    @host, @port, @app = args
    @request_method    = nil
    @path     = nil
    @query    = nil
    @protocol = ::Protocol
  end

  def env
    {
      'PATH_INFO'         => @path,
      'QUERY_STRING'      => @query.to_s,
      'REQUEST_METHOD'    => @request_method,
      'SERVER_NAME'       => Config::SERVER_NAME,
      'SERVER_PORT'       => @port.to_s,
      'rack.version'      => Rack::VERSION,
      'rack.input'        => StringIO.new('').set_encoding('ASCII-8BIT'),
      'rack.errors'       => $stderr,
      'rack.multithread'  => false,
      'rack.multiprocess' => false,
      'rack.run_once'     => false,
      'rack.url_scheme'   => 'http'
    }
  end

  def start
    server = TCPServer.new(@host, @port)

    puts <<~MESSAGE
        #{@app} is running on #{@host}:#{@port}
        => Use Ctrl-C to stop
    MESSAGE

    loop do
      socket = server.accept

      while !socket.closed? && !socket.eof?
        request = socket.readpartial(1024)

        begin
          puts "RECEIVED REQUEST MESSAGE: #{request.inspect.chomp}"

          @request_method = @protocol.http_method(request)
          @path, @query = @protocol.path(request).split('?')

          puts "REQUEST MESSAGE has been translated: #{@request_method} #{@path} HTTP/1.1"

          status, headers, body = @app.call(env)

          socket.write <<~MESSAGE
              #{response_line(status)}
              #{response_header(headers)}\r\n
              #{response_body(body)}
          MESSAGE
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
      "HTTP/1.1 #{status} #{@protocol.http_status_code(status)}"
    end

    def response_header(headers)
      headers.map { |k, v| "#{k}: #{v}" }.join(', ')
    end

    def response_body(body)
      rbody = []
      body.each { |body| rbody << body }
      rbody.join("\n")
    end
end
