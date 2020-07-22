# 引用: Working with TCP Sockets (Jesse Storimer)
# Non-Blocking IO

require 'socket'


client = TCPSocket.new('localhost', 4481)
payload = 'Lorem ipsum' * 10_000

# ノンブロッキングモードで書き込み
# 返り値は書き込んだ長さ
written = client.write_nonblock(payload)
written < payload.size

# 1回の呼び出しでデータをすべて書き込めなかった場合、
# 再書き込みが必要だがwrite(2)がブロックされていると
# Errno::EAGAIN 例外が発生する
# -> ソケットが書き込み可能なタイミングを図るためにIO.selectを使用する
