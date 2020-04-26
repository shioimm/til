# 引用: Working with TCP Sockets (Jesse Storimer)
# Non-Blocking IO

require 'socket'

Socket.tcp_server_loop(4481) do |connection|
  loop do
    begin
      # IO をノンブロッキングモードに設定し、データの最大長を読み込む
      puts connection.read_nonblock(4096)
    rescue Errno::EAGAIN
      # 読み込み待ちするソケットの配列を渡す
      # 与えられた要素の中から準備ができたソケットを配列の配列として返す
      IO.select([connection])
      retry
    rescue EOFError
      break
    end
  end

  connection.close
end
