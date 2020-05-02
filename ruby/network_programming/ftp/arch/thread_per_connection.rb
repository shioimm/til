# 引用: Working with TCP Sockets (Jesse Storimer)
# Thread per Connection

# Spawning
## スレッドの方が低コスト
## スレッドはメモリをコピーするのではなく、メモリを共有するため、
## より高速にプロセスを生成することができる

# Synchronizing
## スレッドはメモリを共有しているため、複数のスレッドにおいて
## ミューテックス、ロック、スレッド間のアクセスが同期している
## プロセスは各プロセスがメモリを独自にコピーしているため、各自が独立している

# Parallelism
## スレッドはプロセスごとに実行されるため、
## 現在の実行コンテキストにおいてグローバルロックを使用する
## プロセスはコピーが行われるたびに
## 新しいプロセスがインタプリタのコピーを取得するため、グローバルロックが存在しない

require 'socket'
require 'thread'
require_relative '../command_handler'

module FTP
  connection = Struct.new(:client) do
    CRLF = "\r\n"

    def gets
      client.gets(CRLF)
    end

    def respond(message)
      client.write(message)
      client.write(CRLF)
    end

    def close
      client.close
    end
  end

  class ThreadPerConnection
    def initialize(port = 21)
      @control_socket = TCPServer.new(port)
      trap(:INT) { exit }
    end

    def run
      # スレッドが例外によって終了した際、インタプリタ全体を中断させる
      Thread.abort_on_exception = true

      loop do
        # 各クライアント接続が単一の独立したスレッドによって処理されるようにする
        conn = Connection.new(@control_socket.accept)

        # スレッドを生成
        Thread.new do
          respond "220 OHAI"

          # スレッドはインスタンスの内部状態を共有するため
          # 各スレッドがそれぞれのConnectionオブジェクトを取得するようにする
          handler = CommandHandler.new(conn)

          loop do
            request = conn.gets

            if request
              conn.respond handler.handle(request)
            else
              conn.close
              break
            end
          end
        end
      end
    end
  end
end

server = FTP::ThreadPerConnection.new(4481)
server.run

# 実装がシンプルでオーバーヘッドが必要ない
# スレッドの方がリソースが軽いため、より多くのスレッドを使用できる
# ロックや共有状態がなく、接続同士を混同することがない
# アクティブなスレッドの数を制限がないため、スレッド数の増加に伴いシステムに負担がかかる
