def foo(a, b)
  x = a + b
  x ** 10
end

p foo(1, 2)

# デバッグ対象となるホスト $ rdbg -O --host $LOCAL_HOST_ADDRESS --port $PORT practices/ruby/debugger/foo.rb
# デバッガにアタッチするホスト $ rdbg -A --host $REMOTE_HOST_ADDRESS --port $PORT
# debug/server.rb: DEBUGGER__::UI_ServerBase#process -> command -> @q_msg (Queue) にリクエストを追加
# lib/debug/session.rb: line = @ui.readline prompt (@ui = UI_TCPServer) リクエストを読み出す
# lib/debug/session.rb: process_commandまたはprocess_protocol_requestで読み出したリクエストを実行する
