# 引用元: rubyネットワークプログラミング / TCPクライアント(エラー処理付き)
# http://www.geekpage.jp/programming/ruby-network/tcp-1.php
# 参照: https://docs.ruby-lang.org/ja/2.6.0/class/tcpserver.html

require 'socket'

begin
  sock = TCPSocket.open('127.0.0.1', 20000)
  raise
rescue
  puts "TCPSocket.open failed : #$!\n"
  # Kernel$$!は最後に例外が発生したExceptionオブジェクトを返す特殊変数
else
  sock.write("Hello")
  sock.close # 引用元ではelseに置かれていたが、ensureでも良さそう
end
