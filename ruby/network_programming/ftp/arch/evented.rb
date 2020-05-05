# 引用: Working with TCP Sockets (Jesse Storimer)
# Evented(Reactor)

# シングルスレッド・シングルプロセスで同時実行性を担保する
# 接続のライフサイクルの各段階が
# 任意の順序でインターリーブして処理することができる個々のイベントとして独立している
# 中心となるmultiplexerはアクティブな接続のイベントを監視し、イベントが発火すると関連するコードを実行する
# 1) サーバーがlisten中のソケットを監視
# 2) サーバーは新しい接続を受け取り、監視対象のソケットのリストに追加
#    サーバーはlisten中のソケットとアクティブな接続を同時に監視している状態
# 3) アクティブな接続が読み込み可能になるとサーバーは通知を受け取る
#    サーバーは接続からデータチャンクを読み取り、関連するコールバックを呼び出す
# 4) サーバーに対してアクティブな接続がまだ読み込み可能であることが通知される
#    サーバーは同じ接続から別のデータチャンクを読み込んで再度コールバックを呼び出す
# 5) サーバーが別の新しい接続を受信し、それを監視するソケットのリストに追加
# 6) 最初の接続が書き込み可能になるとサーバーは通知を受け取る
#    その接続に対してレスポンスが書き込まれる
# ワークフローは単一のスレッドで行われる
# サーバーは複数の接続に関連するイベントをインターリーブできるよう、各操作をチャンクに分割している

require 'socket'
require_relative '../command_handler'

module FTP
  class Evented
    CHUNK_SIZE = 1024 * 16

    # Eventedパターンはシングルスレッドだが、
    # 複数のクライアント接続が同時に処理されるため、
    # 各クライアント接続を独立したオブジェクトとして表現する必要がある
    class Connection
      CRLF = "\r\n"
      attr_reader :client

      def initialize(io)
        @client = io # 接続の基礎となるIO オブジェクトを格納
        @request, @response = '', ''
        @handler = CommandHandler.new(self)

        respond "220 OHAI"
        on_writable
      end

      # クライアント接続からデータを読み込む際、
      # そのデータによってon_dataをトリガーする
      def on_data(data)
        @request << data

        # 完全なリクエストを受信したかどうかを確認する
        # 受信した場合、@handlerにレスポンスの生成を依頼し、再度@responseに割り当てる
        if @request.end_with?(CRLF)
          respond @handler.handle(@request)
          @request = ''
        end
      end

      def respond(message)
        # レスポンスボディを格納
        @response << message + CRLF

        # すぐに書き込めるものはすぐに書き込み、
        # 残りはソケットが書き込めるようになったときにリトライする
        on_writable
      end

      # クライアント接続が書き込み可能になった際に呼び出される
      def on_writable
        # @responseからクライアント接続に書き込めるものを書き込み、
        # 書き込んだ長さを返す
        bytes = client.write_nonblock(@response)
        # 正常に書き込まれたビットを削除
        @response.slice!(0, bytes)
        # 以降は今回書き込めなかった@responseの残り部分が書き込まれる
        # 全体を書き込み終わった場合は@responseは空の文字列にsliceされ、それ以上は書き込まれなくなる
      end

      # 読み込みについて、特定のクライアント接続の状態を監視すべきかどうか
      # 新しいデータが利用可能であれば常に新しいデータを読み込む
      def monitor_for_reading?
        true
      end

      # 書き込みについて、特定のクライアント接続の状態を監視すべきかどうか
      # 書き込まれる@responseがある場合にのみ書き込み可能
      # @responseが空の場合は書き込み不可能
      def monitor_for_writing?
        !(@response.empty?)
      end
    end

    def initialize(port = 21)
      # 実際にクライアント接続を受け入れるソケットを開く
      @control_socket = TCPServer.new(port)
      trap(:INT) { exit }
    end

    def run
      @handles = {} # ex. { 6 => #<FTP::Evented::Connection:xyz123> }

      loop do
        # アクティブな各接続に読み書きを監視するかどうかを確認し、
        # 対象となる各接続についてIO オブジェクトへの参照を取得
        to_read = @handles.values.select(&:monitor_for_reading?).map(&:client)
        to_write = @handles.values.select(&:monitor_for_writing?).map(&:client)

        # ソケットをタイムアウトなしでIO.selectに渡す
        # 監視しているソケットのうち最低一つがイベントを取得するまでブロック
        # 読み取りを監視する@control_socketも
        # 新しいクライアント接続を検出するために接続に含める
        readables, writables = IO.select(to_read + [@control_socket], to_write)

        # IO.selectから受け取ったイベントに基づき、適切なメソッドをトリガーする

        # 読み込み可能と判断されたソケットを処理
        readables.each do |socket|
          if socket == @control_socket # @control_socketが読み込み可能 == 新しいクライアント接続
            # 新しい接続を構築し、@handlesハッシュに挿入し、
            # 次回のループ時に監視
            io = @control_socket.accept
            connection = Connection.new(io)
            @handles[io.fileno] = connection
          else # それ以外のソケットが読み込み可能 == 通常のクライアント接続
            connection = @handles[socket.fileno]

            begin
              # ソケットからデータを読み込み、
              # 該当の接続に対してon_dataメソッドを起動
              data = socket.read_nonblock(CHUNK_SIZE) # CHUNK_SIZEまで読み込み、データがなければErrno::EAGAINを送出
              connection.on_data(data)
            rescue Errno::EAGAIN # 読み取りがブロックされた場合、イベントを通過させる
            rescue EOFError # クライアントが切断された場合、@handles Hashからエントリを削除
              @handles.delete(socket.fileno)
            end
          end
        end

        # 各書き込み可能な接続に対してon_writable メソッドをトリガーし、
        # 書き込み可能ソケットを処理
        writables.each do |socket|
          connection = @handles[socket.fileno]
          connection.on_writable
        end
      end
    end
  end
end

server = FTP::Evented.new(4481)
server.run

# 数千から数万の同時接続を処理することができる
# 処理するプロセス/スレッドがないためシンプル
# ex. EventMachine, Celluloid::IO, Twisted
