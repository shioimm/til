# 引用: Working with TCP Sockets (Jesse Storimer)
# Serial

# Serialアーキテクチャにおいて、すべてのクライアント接続は直列に処理される
# 1) クライアントが接続
# 2) クライアント/サーバーがリクエストとレスポンスを交換
# 3) クライアントが切断
# 上記の流れを繰り返す

require 'socket'
require_relative '../command_handler'

module FTP
  CRLF = "\r\n"

  class Serial
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
      # 接続ソケットにフォーマットしたFTPレスポンスを書き込む
      @client.write(message)
      # 接続ソケットにメッセージの終了を書き込む
      @client.write(CRLF)
    end

    def run
      loop do
        # クライアント接続を受け入れる
        @client = @control_socket.accept
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
    end
  end
end

server = FTP::Serial.new(4481)
server.run

# 実装がシンプルなためロックや共有状態がなく、接続同士を混同することがない
# リソースの使用量を抑えることができる
# 接続が遅い場合、接続が閉じられるまでサーバは次の接続をブロックする
