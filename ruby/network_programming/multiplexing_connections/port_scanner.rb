# 引用: Working with TCP Sockets (Jesse Storimer)
# Multiplexing Connections

# リモートホスト上のポートへの接続を試み、
# どのポートが接続に対してオープンであったかを確認する

require 'socket'

PORT_RANGE = 1..128
HOST = 'archive.org'
TIME_TO_WAIT = 5 # seconds

sockets = PORT_RANGE.map do |port|
  socket = Socket.new(:INET, :STREAM)
  remote_addr = Sock.sockaddr_in(port, 'archive.org')

  begin
    socket.connect_nonblock(remote_addr)
  rescue Errno::EINPROGRESS # ソケットがノンブロッキングであり、接続をすぐに完了できない
  end

  socket
end

expiration = Time.now + TIME_TO_WAIT

loop do
  _, writable, _ = IO.select(nil, sockets, nil, expiration - Time.now)

  break unless writable

  writable.each do |socket|
    begin
      socket.connect_nonblock(socket.remote_addr)
    rescue Errno::EISCONN # ソケットが既に接続されている => 成功
      puts "#{HOST}: #{socket.remote_address.ip_port} accepts connections"
      sockets.delete(socket)
      # 書き込み可能なソケットとして選択され続けないよう、リストからソケットを削除
    rescue Errno::EINVAL # 引数が無効
      sockets.delete(socket)
    end
  end
end
