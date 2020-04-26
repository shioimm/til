# 引用: Working with TCP Sockets (Jesse Storimer)
# Non-Blocking IO

require 'socket'

client = TCPSocket.new('localhost', 4481)
payload = 'Lorem ipsum' * 10_000

begin
  loop do
    bytes = client.write_nonblock(payload)

    break if bytes >= payload.size
    payload.slice!(0, bytes)
    # 2番目の引数に書き込み待ちするソケットの配列を渡す
    # 与えられた要素の中から準備ができたソケットを配列の配列として返す
    IO.select(nil, [client])
  end
rescue Errno::EAGAIN
  IO.select(nil, [client])
  retry
end

# write_nonblockがpayloadのサイズよりも小さい整数を返す場合、
# payloadからそのデータをsliceして、
# ソケットが書き込み可能になった時点でループに戻る

# 書き込みがブロックされるのは、TCPが輻輳制御している場合
# 1) 受信側がまだ保留中のデータの受信を認めていない
# 2) 受信側が受信したデータを処理していない
