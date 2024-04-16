require 'socket'

class Server
  ADDRESS_FAMILIES = {
    ipv6: [Socket::AF_INET6, "::1"],
    ipv4: [Socket::AF_INET,  "127.0.0.1"],
  }

  def initialize(version)
    @version = version
    family, address = ADDRESS_FAMILIES[version]
    @socket  = Socket.new(family, :STREAM)
    sockaddr = Socket.pack_sockaddr_in(9292, address)
    @socket.bind(sockaddr)
    @socket.setsockopt(:SOCKET, :REUSEADDR, true)
    trap(:INT) { @socket.close; exit }
  end

  def accept_loop
    sleep if @version == :ipv6
    @socket.listen(5)

    loop do
      connection, addrinfo = @socket.accept
      connection.readpartial(128)
      connection.write("Connection OK: #{addrinfo.ip_address}\n")
      connection.close
    rescue EOFError => e
      puts "EOFError #{connection}: #{e}"
    end
  end
end

if child_pid = fork
  Server.new(:ipv4).accept_loop
  Process.waitpid(child_pid)
else
  Server.new(:ipv6).accept_loop
end
