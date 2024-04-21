require "socket"

class Server
  ADDRESS_FAMILIES = {
    IPv6: [Socket::AF_INET6, "::1"],
    IPv4: [Socket::AF_INET,  "127.0.0.1"],
  }

  def initialize(version)
    @version = version
    family, address = ADDRESS_FAMILIES[version]
    @socket  = Socket.new(family, :STREAM)
    sockaddr = Socket.pack_sockaddr_in(4567, address)
    @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    @socket.bind(sockaddr)
  end

  def accept_loop
    puts "#{@version} server started"

    sleep if @version == :IPv4

    @socket.listen(5)

    loop do
      connection, addrinfo = @socket.accept
      puts "Received #{@version} request"
      connection.readpartial(128)
      connection.write("Connection OK: #{addrinfo.ip_address} (#{@version})\n")
      connection.close
    rescue EOFError => e
      puts "EOFError #{connection}: #{e}"
    end
  end
end

if child_pid = fork
  Server.new(:IPv6).accept_loop
  Process.waitpid(child_pid)
else
  Server.new(:IPv4).accept_loop
end
