# 引用: Working with TCP Sockets (Jesse Storimer)
# Process per Connection

# クライアント接続を受け入れた後、サーバーがその新しい接続の処理を目的とする子プロセスをforkする
# 子プロセスは接続を処理した後に終了する
# 1) サーバーにクライアント接続が入る
# 2) メインのサーバプロセスが接続を受け入れる
# 3) メインのサーバプロセスのコピーとして新しい子プロセスをfork
# 4) 子プロセスは並列に接続を処理し続け、メインのサーバープロセスは上記の流れを繰り返す
# 接続を受け付けるために待機している親プロセスは1つになり、
# 個々の接続を処理する子プロセスが複数存在する

require 'socket'
require_relative '../command_handler'

module FTP
  class ProcessPerConnection
    CRLF = "\r\n"

    def initialize(port = 21)
      # 実際にクライアント接続を受け入れるソケットを開く
      @control_socket = TCPServer.new(port)
      trap(:INT) { exit }
    end

    def gets
      # 現在のクライアント接続を取得
      # デリミタを明示的に渡す
      @client.gets(CRLF)
    end

    def respond(message)
      # フォーマットしたFTPレスポンスを書き出す
      @client.write(message)
      # メッセージの終了を書き込む
      @client.write(CRLF)
    end

    def run
      loop do
        # クライアント接続を受け入れる
        @client = @control_socket.accept

        # 接続を受け入れた直後にメインのサーバプロセスはforkを呼び出す
        # 子プロセスはブロックを評価して終了する
        # 各接続は単一の独立したプロセスによって処理され、
        # メインのサーバープロセスはブロック内のコードを評価しない
        pid = fork do
          respond "220 OHAI"

          # 接続のたびに現在の作業ディレクトリをカプセル化する
          handler = CommandHandler.new(self)

          # コードを処理している間、サーバーは接続を受け入れない
          loop do
            # クライアントソケットから改行ごとにリクエストメッセージを取得
            request = gets

            if request
              # 受信したリクエストをCommandHandlerオブジェクトに送り、レスポンスメッセージを取得
              respond handler.handle(request)
            else
              @client.close
              break
            end
          end
        end

        Process.detach(pid) # 子プロセスpidの終了を監視するスレッドを生成して返す
      end
    end
  end
end

server = FTP::ProcessPerConnection.new(4481)
server.run

# 実装がシンプルでオーバーヘッドが必要ない
# ロックや共有状態がなく、接続同士を混同することがない
# フォークする子プロセスの数に上限がないため、プロセス数が増えると破綻する
# プロセスとスレッドの使用の問題が発生する
