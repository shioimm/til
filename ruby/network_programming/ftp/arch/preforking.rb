# 引用: Working with TCP Sockets (Jesse Storimer)
# Preforking

# サーバー起動時、クライアント接続前にプロセスをまとめてフォークしておく
# 1) メインサーバープロセスがリスニングソケットを生成
# 2) メインサーバープロセスが子プロセスをまとめてフォーク
# 3) 各子プロセスが共有ソケット上のクライアント接続を受け入れ、それぞれを独立して処理
# 4) メインサーバープロセスは子プロセスを監視する
# メインサーバープロセスはリスニングソケットを生成するが接続を受け付けない

# 子プロセス間の負荷分散や接続の同期はカーネルが処理する
# (複数のプロセスがクライアント接続を受け入れ可能な場合、
# カーネルが負荷のバランスをとり、そのうち1つだけが特定の接続を受け入れるようにする)

require 'socket'
require_relative '../command_handler'

module FTP
  class Preforking
    CRLF = "\r\n"
    CONCURRENCY = 4

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
      child_pids = []

      # CONCURRENCYの回数分spawn_child メソッドを呼び出す
      CONCURRENCY.times do
        child_pids << spawn_child # spawn_childは新しいプロセスをforkし、一意のpidを返す
      end

      # 親プロセスによってINTシグナルハンドラを定義(中断時のシグナルを受け取る)
      # 親プロセスが受信したINTシグナルを子プロセスに転送する
      trap(:INT) {
        child_pids.each do |cpid|
          begin
            Process.kill:INT, (cpid) # 親プロセスが終了する前に子プロセスをkillする
          rescue Errno::ESRCH
          end
        end

        exit
      }

      loop do
        # 子プロセスのひとつが終了するまで待つ
        # pid = 終了した子プロセスのpid
        pid = Process.wait
        $stderr.puts "Process #{pid} quit unexpectedly"

        child_pids.delete(pid)
        child_pids << spawn_child # 終了した子プロセスの代わりに新しい子プロセスを生成
      end
    end

    def spawn_child
      fork do # クライアント接続を受け入れる前に新しい子プロセスがforkされる
        loop do # それぞれの接続が処理されて閉じる際、新しい接続が処理される
          @client = @control_socket.accept
          respond "220 OHAI"

          handler = CommandHandler.new(self)

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
end

server = FTP::Preforking.new(4481)
server.run

# プロセスが過剰に生成されない
# あるプロセスで障害が発生しても他のプロセスには影響を与えない
# プロセスをforkすることによりサーバのメモリ消費量は増える
# (forkごとにメモリ使用量が親プロセスの最大100%増加する)
# ex. Unicorn
