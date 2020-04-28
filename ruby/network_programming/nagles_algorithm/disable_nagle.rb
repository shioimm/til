# 引用: Working with TCP Sockets (Jesse Storimer)
# Nagle's Algorithm

# バッファリングを行わず、一度に少量のデータを送信するアプリケーション向けの最適化
# 1) TCPパケット全体を構成する十分なデータがローカルバッファにある場合、すぐに送信する
# 2) ローカルバッファに保留中のデータがなく、受信側からの受信確認応答が保留中でない場合、すぐに送信する
# 3) 相手の受信確認が保留中で、TCPパケット全体を構成するのに十分なデータがない場合、データをローカルバッファに入れる

require 'socket'

server = TCPServer.new(4481)

server.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
# Socket::IPPROTO_TCP -> Transmission control protocol
# Socket::TCP_NODELAY -> Don't delay sending to coalesce packets
# Nagle's Algorithmを無効にし、遅延なしで送信させる
