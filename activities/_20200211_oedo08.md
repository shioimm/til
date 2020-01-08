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
- `MyServer::Server`の実行
  - ソケットの作成
    - ソケットでリクエストを受け付ける
    - ソケットでレスポンスを返す
      - Rackアプリケーションの実行
```ruby
require 'socket'
require_relative './rack/handler/my_server'

module MyServer
  class Server
    # Rackアプリケーションの実行に必要な環境変数
    # lib/rack/lint.rb:67 Rack::Lint#check_env
    # PEP333から採用 => https://knzm.readthedocs.io/en/latest/pep-0333-ja.html
    RACK_ENV = {
      'PATH_INFO'         => '/',           # -> リクエストURLのうちドメイン下層のパス
      'QUERY_STRING'      => '',            # -> リクエストURLのうち?以降のクエリ文字列
      'REQUEST_METHOD'    => 'GET',         # -> HTTPリクエストメソッド
      'SERVER_NAME'       => 'MY_SERVER',   # -> SCRIPT_NAME、PATH_INFOとの組み合わせでURLを構築する
      'SERVER_PORT'       => @port.to_s,    # -> SCRIPT_NAME、PATH_INFOとの組み合わせでURLを構築する
      'rack.version'      => Rack::VERSION, # -> Rackのバージョンを表す配列

      'rack.input'        => StringIO.new('').set_encoding('ASCII-8BIT'), # -> 入力ストリーム / HTTP POSTデータを含むIO likeなオブジェクト
      'rack.errors'       => $stderr, # -> エラーストリーム / puts、write、flushメソッドに対応するオブジェクト
      'rack.multithread'  => false,   # -> アプリケーションが同じプロセス内の別のスレッドによって同時に呼び出されるかどうか
      'rack.multiprocess' => false,   # -> アプリケーションが別のプロセスによって同時に呼び出されるかどうか
      'rack.run_once'     => false,   # -> アプリケーションがそのプロセスの実行中に一度だけ起動されるかどうか(CGIのみ)
      'rack.url_scheme'   => 'http',  # -> http or https
    }

    def initialize(*args)
      @host, @port, @app = args # Rack::Handler::MyServer.runから引き継いだ引数
      @status = nil
      @header = nil
      @body   = nil
    end

    def start
      server = TCPServer.new(@host, @port)

      # サーバー起動時メッセージを出力
      puts <<~MESSAGE
        #{@app} is running on #{@host}:#{@port}
        => Use Ctrl-C to stop
      MESSAGE

      loop do
        client = server.accept
        # クライアントからの接続要求を受け付け、
        # 接続したソケット(TCPSocketのインスタンス)を取得

        begin
          request = client.readpartial(2048)
          # クライアントから送信されたリクエストを読み込み、文字列として取得
          # IO#readpartialはデータを受け取るまではブロック状態を保つ

          puts request.split("\r\n")[0..1]
          # リクエストを受信したことがわかるように、リクエストメッセージの一部を出力

          @status, @header, @body = @app.call(RACK_ENV)
          # Rackアプリケーションを実行して返り値を取得

          client.puts <<~MESSAGE
            #{status}
            #{header}\r\n
            #{body}
          MESSAGE
        ensure
          client.close
          # レスポンスを送信後にソケットを閉じる
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
      # レスポンスボディとしてRack::BodyProxyのインスタンスが返ってくるため、
      # Rack::BodyProxy#eachで内容を取得する
      res_body = []
      @body.each { |body| res_body << body }
      res_body.join("\n")
    end
  end
end
```
