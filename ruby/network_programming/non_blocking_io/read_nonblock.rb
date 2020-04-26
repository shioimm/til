# 引用: Working with TCP Sockets (Jesse Storimer)
# Non-Blocking IO

require 'socket'

Socket.tcp_server_loop(4481) do |connection|
  loop do
    begin
      # IO をノンブロッキングモードに設定し、データの最大長を読み込む
      puts connection.read_nonblock(4096)
    rescue Errno::EAGAIN
      # 与えられたIOオブジェクトから準備ができたものを配列にし、配列の配列として返す
      IO.select([connection])
      retry
    rescue EOFError
      break
    end
  end

  connection.close
end
