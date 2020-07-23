# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

server = Socket.new(:INET, :STREAM)
addr = Socket.pack_sockaddr_in(4481, '0.0.0.0')
server.bind(addr)
server.listen(128)

loop do
  # acceptはひとつのコネクションを返した後、終了する
  # 継続的にコネクションをリッスンするためにはループ処理が必要
  connection, _ = server.accept

  # ソケットへの明示的な参照を切ることにより
  # リソースを節約し、オープンファイルの上限到達を回避するために
  # 明示的なcloseを行う
  connection.close
end
