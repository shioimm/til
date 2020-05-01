# 引用: Working with TCP Sockets (Jesse Storimer)
# Urgent Data

for_reading = [<TCPSocket>, <TCPSocket>, <TCPSocket>]
for_writing = [<TCPSocket>, <TCPSocket>, <TCPSocket>]

IO.select(for_reading, for_writing, for_reading)
# 緊急のデータは第三引数の配列に含まれる
