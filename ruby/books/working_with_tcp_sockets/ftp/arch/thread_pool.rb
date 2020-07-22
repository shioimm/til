# 引用: Working with TCP Sockets (Jesse Storimer)
# Thread Pool

# Preforkingのプロセスをスレッドに置き換えたアーキテクチャ
# サーバー起動時にスレッドをまとめて生成し、それぞれの独立したスレッドで接続処理を行う

require 'socket'
require 'thread'
require_relative '../command_handler'

module FTP
  Connection = Struct.new(:client) do
    CRLF = "\r\n"

    def gets
      # 現在のクライアント接続を取得
      # デリミタを明示的に渡す
      client.gets(CRLF)
    end

    def respond(message)
      # 接続ソケットにフォーマットしたFTPレスポンスを書き込む
      client.write(message)
      # 接続ソケットにメッセージの終了を書き込む
      client.write(CRLF)
    end

    def close
      # クライアント接続を閉じる
      client.close
    end
  end

  class ThreadPool
    CONCURRENCY = 25

    def initialize(port = 21)
      # 実際にクライアント接続を受け入れるソケットを開く
      @control_socket = TCPServer.new(port)
      trap(:INT) { exit }
    end

    # スレッドの生成と動作をカプセル化
    def run
      # スレッドが例外によって終了した際、インタプリタ全体を中断させる
      Thread.abort_on_exception = true
      threads = ThreadGroup.new # スレッドグループを生成

      # CONCURRENCYの回数分spawn_threadメソッドを呼び出す
      # スレッドは軽量化されているため、プロセスよりも数を増やすことができる
      CONCURRENCY.times do
        threads.add spawn_thread # 新しいスレッドを生成してスレッドグループに追加
        # スレッドの実行終了時、スレッドはスレッドグループから削除される
      end

      sleep # プールの終了を防ぐためにsleepさせる
    end

    # 接続処理コードをループするスレッドを生成
    # カーネルの処理により、単一の接続が単一のスレッドにのみ受け入れられるようになっている
    def spawn_thread
      Thread.new do
        loop do
          conn = Connection.new(@control_socket)
          conn.respond "220 OHAI"

          # スレッドはインスタンスの内部状態を共有するため
          # 各スレッドがそれぞれのConnectionオブジェクトを取得するようにする
          handler = CommandHandler.new(conn)

          loop do
            # クライアントソケットから改行ごとにリクエストメッセージを取得
            request = conn.gets

            if request
              # 受信したリクエストをCommandHandlerオブジェクトに送り、レスポンスメッセージを取得
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

server = FTP::ThreadPool.new(4481)
server.run

# 接続を処理するたびにスレッドを生成する必要がない
# ロックや競合条件を持たずに並列処理を行うことができる
# ex. Puma
