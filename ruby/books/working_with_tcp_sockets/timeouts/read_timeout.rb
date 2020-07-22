# 引用: Working with TCP Sockets (Jesse Storimer)
# Timeouts

require 'socket'
require 'timeout'

timeout = 5 # seconds

Socket.tcp_server_loop(4481) do |connection|
  begin
    connection.read_nonblock(4096) # 接続ソケットから4096byteまで読み込み、データがなければErrno::EAGAINを送出
  rescue Errno::EAGAIN # ノンブロッキング操作がブロックされた場合
    # コネクションが読み込み可能か監視
    if IO.select([connection], nil, nil, timeout)
      # 返り値がある場合はretry
      retry
    else
      raise Timeout::Error # 関数timeoutがタイムアウト
    end
  end

  connection.close
end
