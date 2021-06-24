require 'socket'
require "stringio"
require_relative './rack/handler/server'
require_relative './protocols/quack/server_protocol'
require_relative './protocols/ruby/server_protocol'

class Server
  def initialize(*args)
    @host, @port, @app = args
    @method = nil
    @path   = nil
    @schema = nil
    @query  = nil
    @status = nil
    @header = nil
    @body   = nil
  end

  def env
    {
      'PATH_INFO'         => @path   || '/',
      'QUERY_STRING'      => @query  || '',
      'REQUEST_METHOD'    => @method || 'GET',
      'SERVER_NAME'       => 'SERVER',
      'SERVER_PORT'       => @port.to_s,
      'rack.version'      => Rack::VERSION,
      'rack.input'        => StringIO.new('').set_encoding('ASCII-8BIT'),
      'rack.errors'       => $stderr,
      'rack.multithread'  => false,
      'rack.multiprocess' => false,
      'rack.run_once'     => false,
      'rack.url_scheme'   => @schema&.downcase&.slice(/http[a-z]*/) || 'http'
    }
  end

  def start
    protocol = ::Quack::ServerProtocol.new
    server = TCPServer.new(@host, @port)

    puts <<~MESSAGE
        #{@app} is running on #{@host}:#{@port}
        => Use Ctrl-C to stop
    MESSAGE

    loop do
      client = server.accept

      while !client.closed? && !client.eof?
        request = client.readpartial(1024)

        begin
          puts "RECEIVED REQUEST MESSAGE: #{request.inspect.chomp}"

          protocol.receive!(request)
          @method, path, @schema = protocol.method, protocol.path, 'http'
          @path, @query = path.split('?')

          puts "REQUEST MESSAGE has been translated: #{@method} #{@path} #{@schema}"

          @status, @header, @body = @app.call(env)

          client.write <<~MESSAGE
              #{status}
              #{header}\r\n
              #{body}
          MESSAGE
        rescue StandardError => e
          puts "#{e.class} #{e.message} - closing socket."
          e.backtrace.each { |l| puts "\t" + l }
          server.close
        ensure
          client.close
        end
      end
    end
  end

  def status
    "#{@schema} 200 OK" if @status.eql? 200
  end

  def header
    @header.map { |k, v| "#{k}: #{v}" }.join(', ')
  end

  def body
    res_body = []
    @body.each { |body| res_body << body }
    res_body.join("\n")
  end
end
