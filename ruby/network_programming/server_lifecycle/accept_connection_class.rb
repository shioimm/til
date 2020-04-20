# 引用: Working with TCP Sockets (Jesse Storimer)
# Server Lifecycle

require 'socket'

server = Socket.new(:INET, :STREAM)
addr = Socket.pack_sockaddr_in(4481, '0.0.0.0')
server.bind(addr)
server.listen(128)

# コネクションをacceptする
connection, _ = server.accept

print 'Connection class: '
p connection.class

print 'Server fileno: '
p server.fileno

print 'Connection fileno: '
p connection.fileno

print 'Local address: '
p connection.local_address

print 'Remote address: '
p connection.remote_address

# Connection class: Socket
# Server fileno: 9
# Connection fileno: 10
# Local address: #<Addrinfo: 127.0.0.1:4481 TCP>
# Remote address: #<Addrinfo: 127.0.0.1:49925 TCP>

# serverソケットとconnectionソケットは別のソケット
# 各connectionはserverソケットとは別の個別のソケットオブジェクトとしてインスタンスを生成する

# connectionオブジェクトはローカルアドレスとリモートアドレスを持つ
# ローカルアドレス -> ローカルマシン上のエンドポイント
# リモートアドレス -> 相手側のエンドポイント
# 各TCP接続は、local-host、local-port、remote-host、remote-portの一意の組み合わせによって定義される
# -> 単一のlocal-hostあるいはremote-hostに対して一意のポート番号で複数の接続を持つことができる
