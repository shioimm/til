# 引用: Working with TCP Sockets (Jesse Storimer)
# Multiplexing Connections

connections = [<TCPSocket>, <TCPSocket>, <TCPSocket>]

loop do
  connections.each do |conn|
    begin
      # ノンブロッキングで各コネクションから読み込みを試行する
      # 受信したデータを処理し、次の接続を試行する
      data = conn.read_nonblock(4096) # 接続ソケットから4096byteまで読み込む、データがなければErrno::EAGAINを送出
      process(data)
    rescue Errno::EAGAIN # ノンブロッキング操作がブロックされた場合
    end
  end
end
