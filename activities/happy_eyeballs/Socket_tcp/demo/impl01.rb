require 'socket'

class Socket
  def self.tcp(host, port)
    mutex = Mutex.new
    cond = ConditionVariable.new
    addrinfos = []
    writable_sockets = []
    connecting_sockets = {}
    connected_socket = nil

    threads = [Socket::AF_INET6, Socket::AF_INET].map { |family|
      args = { host:, port:, family:, addrinfos:, mutex:, cond: }

      Thread.new(args) { |args|
        addrinfos = Addrinfo.getaddrinfo(args[:host], args[:port], args[:family], Socket::SOCK_STREAM)

        args[:mutex].synchronize do
          sleep 0.05 if addrinfos.last == Socket::AF_INET && addrinfos.any? { |ai| ai == Socket::AF_INET6 }

          args[:addrinfos].concat addrinfos
          args[:cond].signal
        end
      }
    }

    connected_socket = loop do
      # 名前解決できない場合はここでとまるのでは?
      #   両方アドレスファミリの名前解決に失敗した場合
      #   両方のアドレスファミリの名前解決が終わっている場合
      # 二周目のループで、この時点ですでに接続確立していても以下の処理を行なっている
      mutex.synchronize do
        cond.wait(mutex) if addrinfos.empty?
        addrinfo = addrinfos.shift
      end

      socket = Socket.new(addrinfo.afamily, addrinfo.socktype, addrinfo.protocol)

      socket.connect_nonblock(addrinfo, exception: false)
      connecting_sockets[socket] = addrinfo

      _, writable_sockets, = IO.select(nil, connecting_sockets.keys, nil, 0.25)
      # すべてのIPアドレスの接続に失敗したあと、まだ名前解決できていないファミリがあったらどうする?
      connected_socket = pick_connected_socket(writable_sockets, connecting_sockets)
      break connected_socket if connected_socket
    end

    connecting_sockets.each do |socket, _|
      socket.close if socket.fileno != connected_socket.fileno
    end
    threads.each(&:exit)
    connected_socket
  end

  def self.pick_connected_socket(writable_sockets, connecting_sockets)
    connected_socket = writable_sockets&.find do |socket|
      begin
        socket.connect_nonblock(connecting_sockets[socket])
      rescue Errno::EISCONN # already connected
        true
      rescue
        false
      end
    end

    connected_socket
  end
end

connected_socket = Socket.tcp("localhost", 9292)
connected_socket.write "Socket.tcp\r\n"
print connected_socket.read
connected_socket.close
