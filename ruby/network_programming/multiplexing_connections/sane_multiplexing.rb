# 引用: Working with TCP Sockets (Jesse Storimer)
# Multiplexing Connections

for_reading, for_writing = [[], []]
timeout = 10

loop do
  ready = IO.select(for_reading, for_writing, for_reading, timeout)
  # 読み込み待ち、書き込み待ち、例外待ち、秒単位のタイムアウト値
  # 返り値は最初の引数として渡したソケットの配列のサブセットになる
  # IOステータスが変更される前にタイムアウトした場合の返り値はnil

  # 読み込みの用意ができたソケットを取得
  readable_connections = ready[0]
  readable_connections.each do |conn|
    data = conn.readpartial(4096)
    process(data)
  end
end

# Object#to_io
# => 変換可能なオブジェクトをIOオブジェクトへ変換
# IO.selectの引数として渡すことができる
