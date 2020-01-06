# Simplest Rack Compatible TCP Server
- [shioimm/simplest_rack_compatible_server](https://github.com/shioimm/simplest_rack_compatible_server)
- [rack/rack](https://github.com/rack/rack)

### rack/handler/my_server.rb
- `Rack::Handler`モジュールの拡張
  - 1. `run`メソッドの実装
  - 2. Handlers(`@handlers`)にサーバーを登録

```ruby
require 'rack/handler'

# rack/lib/rack/handler.rb:4
# *Handlers* connect web servers with Rack.
#
# Rack includes Handlers for Thin, WEBrick, FastCGI, CGI, SCGI
# and LiteSpeed.
#
# Handlers usually are activated by calling <tt>MyHandler.run(myapp)</tt>.
# A second optional hash can be passed to include server-specific
# configuration.
# -> HandlersはWebサーバーをRackに接続する
# -> Handlersは MyHandler.run(myapp) によってアクティブになる

module Rack
  module Handler
    class MyServer
      def self.run(app, options = {})
        # 実行環境、ホスト、ポートの設定
        environment  = ENV['RACK_ENV'] || 'development'
        default_host = environment == 'development' ? 'localhost' : '0.0.0.0'

        # オプションが受け取れるようになっている
        # オプションの設定はrack/lib/rack/server.rb:13 Rack::Server::Options
        host = options.delete(:Host) || default_host
        port = options.delete(:Port) || 9292
        args = [host, port, app]

        # 別途実装したMyServer::Serverクラスをインスタンス化し、startメソッドで実行
        ::MyServer::Server.new(*args).start
      end
    end

    # Rack::Handler::MyServer.runは
    # lib/rack/server.rb:331でRack::Server#startメソッドから呼ばれている

    register :my_server, MyServer

    # rack/lib/rack/handler.rb:85
    # def self.register(server, klass)
    #   @handlers ||= {}
    #   @handlers[server.to_s] = klass.to_s
    # end
    # -> @handlers = { 'my_server' => 'MyServer' }
    # Rack::Handler.registerを実行し、Handlers(@handlers)にサーバーを登録

    # Handlers(@handlers)はRack::Handler.getで使用されている
    # rack/lib/rack/handler.rb:13
    # def self.get(server)
    #   ...略...
    #   if klass = @handlers[server]
    #     const_get(klass) -> Rack::Handler::MyServer
    #   else
    #     const_get(server, false)
    #   end
    #   ...略...
    # end

    # Rack::Handler.getはlib/rack/server.rb:334 Rack::Server#server
    # あるいはlib/rack/handler.rb:36 Rack::Handler.pick:36で呼ばれ、
    # 通信に利用するサーバーを返す

    # つまりRack::Handler::registerによってMyServerを登録し、
    # Rack::Handler::MyServer.runメソッドによってMyServerを起動している

    # lib/rack.rb:106
    # autoload :Handler, "rack/handler"
    # -> 定数Handlerを最初に参照した時にrequire "rack/handler"する
  end
end
```

### my_server.rb
WIP
```ruby
require 'socket'
require_relative './rack/handler/my_server'

module MyServer
  class Server
    RACK_ENV = {
      'PATH_INFO'         => '/',
      'QUERY_STRING'      => '',
      'REQUEST_METHOD'    => 'GET',
      'SERVER_NAME'       => 'MY_SERVER',
      'SERVER_PORT'       => @port.to_s,
      'rack.version'      => Rack::VERSION,
      'rack.input'        => StringIO.new('').set_encoding('ASCII-8BIT'),
      'rack.errors'       => $stderr,
      'rack.multithread'  => false,
      'rack.multiprocess' => false,
      'rack.run_once'     => false,
      'rack.url_scheme'   => 'http',
    }

    def initialize(*args)
      @host, @port, @app = args
      @status = nil
      @header = nil
      @body   = nil
    end

    def start
      server = TCPServer.new(@host, @port)

      puts <<~MESSAGE
        #{@app} is running on #{@host}:#{@port}
        => Use Ctrl-C to stop
      MESSAGE

      loop do
        client = server.accept

        begin
          request = client.readpartial(2048)
          puts request.split("\r\n")[0..1]

          @status, @header, @body = @app.call(RACK_ENV)

          client.puts <<~MESSAGE
            #{status}
            #{header}\r\n
            #{body}
          MESSAGE
        ensure
          client.close
        end
      end
    end

    def status
      "HTTP/1.1 200 OK" if @status.eql? 200
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
end
```
