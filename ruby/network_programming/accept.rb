# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

server = Socket.new(:INET, :STREAM)
addr = Socket.pack_sockaddr_in(4481, '0.0.0.0')
server.bind(addr)
server.listen(128)

# コネクションをacceptする
connection, _ = server.accept

# acceptコールはブロッキングコールであり、
# 新しい接続を受け取るまで現在のスレッドを無期限にブロックする
# 利用可能なコネクションがない場合は次のコネクションがプッシュされるのを待つ

# acceptコールは
# ・接続
# ・Addrinfoオブジェクト(クライアント接続のリモートアドレス)
# の二つの値を返す

# Addrinfoクラスはソケットのアドレス情報(ホストとポート番号)を保持する
