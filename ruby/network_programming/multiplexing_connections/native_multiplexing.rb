# 引用: Working with TCP Sockets (Jesse Storimer)
# Multiplexing Connections

connections = [<TCPSocket>, <TCPSocket>, <TCPSocket>]

loop do
  connections.each do |conn|
    begin
      # ノンブロッキングで各コネクションから読み込みを試行する
      # 受信したデータを処理し、次の接続を試行する
      data = conn.read_nonblock(4096)
      process(data)
    rescue Errno::EAGAIN # リソースが一時的に利用不可
    end
  end
end
