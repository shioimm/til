# 引用: Working with TCP Sockets (Jesse Storimer)
# Sockets Can Read

require 'socket'

one_handred_kb = 1024 * 100

Socket.tcp_server_loop(4481) do |connection|
  begin
    # 最大長を上限として読み込み、文字列として返す
    # EOFイベントを受け取るとEOFErrorが発生
    while data = connection.readpartial(one_handred_kb) do
      puts data
    end
  rescue EOFError
  end

  connection.close
end

# readはlazy -> 最小長を満たすまでのデータをバッファする
# readpartialはeager -> 最大長に達するまでのデータを読み込む
