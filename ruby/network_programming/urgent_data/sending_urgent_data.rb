# 引用: Working with TCP Sockets (Jesse Storimer)
# Urgent Data

# Socket#send
# -> ソケットを介してデータを送信する(引数なしの場合はwriteと同様)

require 'socket'

socket = TCPSocket.new('localhost', 4481)

socket.write('first')
socket.write('second')

socket.send('!', Socket::MSG_OOB) # Process out-of-band data
