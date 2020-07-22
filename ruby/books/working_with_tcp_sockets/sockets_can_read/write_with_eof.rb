# 引用: Working with TCP Sockets (Jesse Storimer)
# Sockets Can Read

require 'socket'

client = TCPSocket.new('localhost', 4481)
# # 接続ソケットにデータを書き込む
client.write('gekko')
client.close

# クライアントがソケットを閉じることによりEOFイベントを送信する
