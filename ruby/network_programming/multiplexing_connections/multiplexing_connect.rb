# 引用: Working with TCP Sockets (Jesse Storimer)
# Multiplexing Connections

require 'socket'

socket = Socket.new(:INET, :STREAM)
remote_addr = Socket.pack_sockaddr_in(80, 'google.com')

begin
  # すぐに接続できなかった場合Errno::EINPROGRESSが発生する
  socket.connect_nonblock(remote_addr)
rescue Errno::EINPROGRESS # ソケットがノンブロッキングであり、接続をすぐに完了できない
  # Errno::EINPROGRESS例外を捕捉
  # バックグラウンドでソケットのステータスの変化を捕捉
  # ステータスが変化したとき、基礎となる接続が完了したことを示す
  IO.select(nil, [socket])

  begin
    socket.connect_nonblock(remote_addr)
  rescue Errno::EISCONN # ソケットが既に接続されている => 成功
  rescue Errno::ECONNREFUSED # リモートアドレスで接続待ち中のプログラムが存在しない
  end
end
