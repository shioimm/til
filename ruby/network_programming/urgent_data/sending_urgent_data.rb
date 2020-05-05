# 引用: Working with TCP Sockets (Jesse Storimer)
# Urgent Data

# Socket#send
# -> ソケットを介してデータを送信する(引数なしの場合はwriteと同様)

require 'socket'

socket = TCPSocket.new('localhost', 4481)

socket.write('first') # 接続ソケットにデータを書き込む
socket.write('second') # 接続ソケットにデータを書き込む

socket.send('!', Socket::MSG_OOB) # Process out-of-band data
